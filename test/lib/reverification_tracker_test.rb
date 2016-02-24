require 'test_helper'

class ReverificationTrackerTest < ActiveSupport::TestCase

  class HardBounceBody
    def body_message_as_h
      { 'bounce': {
          'bounceType': 'Permanent',
          'bouncedRecipients': [{ 'emailAddress': 'bounce@simulator.amazonses.com' }]
        } 
      }.with_indifferent_access
    end
  end

  class HardBounceMessage
    def as_sns_message
      HardBounceBody.new
    end
  end

  class TransientBounceBody
    def body_message_as_h
      { 'bounce': {
          'bounceType': 'Transient',
          'bouncedRecipients': [{ 'emailAddress': 'ooto@simulator.amazonses.com' }]
        } 
      }.with_indifferent_access
    end
  end

  class TransientBounceMessage
    def as_sns_message
      TransientBounceBody.new
    end

    def body
      'ooto@simulator.amazonses.com'
    end
  end

  class SuccessBody
    def body_message_as_h
      {'mail': {
       'delivery': 
          {'recipients': ['success@simulator.amazonses.com'] } 
        }
      }.with_indifferent_access
    end
  end

  class SuccessMessage
    def as_sns_message
      SuccessBody.new
    end
  end

 #Note: I need to test the mechanics of time_is_right? method.

  describe 'ReverificationTracker' do
    describe 'first notification phase' do
      describe 'sending the first notification' do
        it 'should only select accounts that have not verified' do
          create(:unverified_account, :success)
          create(:unverified_account, :complaint)
          create(:unverified_account, :hard_bounce)
          create(:unverified_account, :soft_bounce)
          create(:account)
          assert_equal 4, ReverificationTracker.unverified_accounts(5).count
          assert_not_equal Account.count, ReverificationTracker.unverified_accounts(5).count
        end

        it 'should only send notifications to accounts that do not have verifications only' do
          correct_account = create(:account)
          create_list(:unverified_account, 4)
          first_notice = ReverificationTracker.first_reverification_notice(correct_account.email)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(first_notice).never
          AWS::SimpleEmailService.any_instance.expects(:send_email).times(4)
          ReverificationTracker.send_first_notification
        end

        it 'should not resend if the ses limit is reached' do
          ReverificationTracker.expects(:ses_limit_reached?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).never
          ReverificationTracker.send_first_notification
        end
      end

      describe 'success scenario' do
        before do
          @success_account = create(:unverified_account, :success)
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(SuccessMessage.new).once
          ReverificationTracker.stubs(:success_queue).returns(mock_queue)
        end

        it "should expect to create a reverification tracker" do
          ReverificationTracker.expects(:find_account_by_email).returns(@success_account).once
          ReverificationTracker.expects(:create_reverification_tracker).with(@success_account).once
          ReverificationTracker.poll_success_queue
        end

        it "should create a reverification tracker with 'initial' status" do
          reverification_tracker = create(:reverification_tracker, account_id: @success_account.id)
          ReverificationTracker.stubs(:find_account_by_email).returns(@success_account)
          ReverificationTracker.stubs(:create_reverification_tracker).with(@success_account).returns(reverification_tracker)
          ReverificationTracker.poll_success_queue
          assert 1, ReverificationTracker.first
          assert 'initial', ReverificationTracker.first.status
        end
      end

      describe 'transient bounce scenario' do
        before do
          @transient_account = create(:unverified_account, :soft_bounce)
          @first_notice = ReverificationTracker.first_reverification_notice(@transient_account.email)
        end

        it 'should retry the first reverification notice' do
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
          ReverificationTracker.stubs(:transient_bounce_queue).returns(mock_queue)
          ReverificationTracker.stubs(:transient_bounce_queue).returns(mock_queue)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(@first_notice).once
          ReverificationTracker.poll_transient_bounce_queue
        end

        it 'should not resend if the ses limit is reached' do
          ReverificationTracker.expects(:ses_limit_reached?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(@first_notcie).never
          ReverificationTracker.poll_transient_bounce_queue
        end
      end

      describe 'hard bounce scenario' do
        before do
          @hard_account = create(:unverified_account, :hard_bounce)
          @mock_queue = mock('AWS::SQS::Queue::MOCK')
        end

        it 'should delete any account that is a hard permanent bounce' do
          @mock_queue.stubs(:poll).yields(HardBounceMessage.new).once
          ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
          ReverificationTracker.expects(:store_email_for_later_retry).never
          ReverificationTracker.expects(:destroy_account)
          ReverificationTracker.poll_bounce_queue
        end

        it 'should send a soft bounce to the transient bounce queue' do
          @mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
          ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
          ReverificationTracker.expects(:store_email_for_later_retry).once
          ReverificationTracker.expects(:destroy_account).never
          ReverificationTracker.poll_bounce_queue
        end
      end
    end

    describe 'mark as spam phase (2nd phase)' do
      describe 'sending the marked for spam notification' do
        it 'should retrieve accounts that only received the first notice' do
          create_list(:first_phase_account, 4)
          create_list(:unverified_account, 1)
          assert_equal 4, ReverificationTracker.first_phase_accounts(5).count
        end

        it "should send a 'marked for spam' notification to the correct account when the time is right" do
          account = create(:first_phase_account)
          unverified_account = create(:unverified_account)
          verified_account = create(:account)
          marked_for_spam_notice = ReverificationTracker.marked_for_spam_notice(account.email)
          wrong_notice_one = ReverificationTracker.marked_for_spam_notice(unverified_account.email)
          wrong_notice_two = ReverificationTracker.marked_for_spam_notice(verified_account.email)
          ReverificationTracker.expects(:find_account_by_email).with(account.email).returns(account)
          ReverificationTracker.expects(:find_account_by_email).with(unverified_account).never
          ReverificationTracker.expects(:find_account_by_email).with(verified_account).never
          ReverificationTracker.stubs(:time_is_right?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(marked_for_spam_notice).once
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_one).never
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_two).never
          ReverificationTracker.send_marked_for_spam_notification
        end

        it "should not send a 'marked for spam' notification to any account when the time is premature" do
          incorrect_account = create(:first_phase_account)
          marked_for_spam_notice = ReverificationTracker.marked_for_spam_notice(incorrect_account.email)
          ReverificationTracker.expects(:find_account_by_email).with(incorrect_account.email).returns(incorrect_account)
          ReverificationTracker.stubs(:time_is_right?).returns(false)
          AWS::SimpleEmailService.any_instance.expects(:send_email).never
          ReverificationTracker.send_marked_for_spam_notification
        end

        it 'should not send an account when the ses limit is reached' do
          correct_account = create(:first_phase_account)
          ReverificationTracker.expects(:ses_limit_reached?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_account).never
          ReverificationTracker.send_marked_for_spam_notification
        end
      end

      describe 'success scenario' do
        it "should expect to correctly update the reverification tracker status and updated_at" do
          account = create(:first_phase_account)
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(SuccessMessage.new).once
          ReverificationTracker.stubs(:success_queue).returns(mock_queue)
          Account.expects(:find_by_email).returns(account).once
          ReverificationTracker.expects(:update_reverification_tracker).with(account)
          ReverificationTracker.poll_success_queue
        end

        it 'should update a reverification tracker with marked for spam and current time' do
          past = DateTime.now.utc - 13.days
          account = create(:first_phase_account, created_at: past, updated_at: past)
          ReverificationTracker.update_reverification_tracker(account)
          assert_equal 'marked for spam', account.reverification_tracker.status
          assert_equal DateTime.now.in_time_zone.to_i, account.reverification_tracker.updated_at.to_i
          assert_not_equal past, account.reverification_tracker.updated_at
        end
      end

      describe 'transient bounce scenario' do
        it "should retry the correct email" do
          correct_account = create(:first_phase_account, email: 'ooto@simulator.amazonses.com')
          incorrect_account = create(:unverified_account)
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
          correct_notice = ReverificationTracker.marked_for_spam_notice(correct_account.email)
          incorrect_notice = ReverificationTracker.marked_for_spam_notice(incorrect_account.email)
          ReverificationTracker.stubs(:transient_bounce_queue).returns(mock_queue)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_notice).once
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(incorrect_notice).never
          ReverificationTracker.poll_transient_bounce_queue
        end

        it 'should not resend if the ses limit is reached' do
          correct_account = create(:first_phase_account, email: 'ooto@simulator.amazonses.com')
          ReverificationTracker.expects(:ses_limit_reached?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_account).never
          ReverificationTracker.poll_transient_bounce_queue
        end
      end

      describe 'hard bounce scenario' do
        before do
          @mock_queue = mock('AWS::SQS::Queue::MOCK')
        end

        it 'should delete an account that is a hard permanent bounce' do
          hard_account = create(:first_phase_account, email: 'bounce@simulator.amazonses.com')
          @mock_queue.stubs(:poll).yields(HardBounceMessage.new).once
          ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
          ReverificationTracker.expects(:store_email_for_later_retry).never
          ReverificationTracker.expects(:destroy_account)
          ReverificationTracker.poll_bounce_queue
        end

        it 'should send a soft bounce to the transient bounce queue' do
          transient_account = create(:first_phase_account, email: 'ooto@simulator.amazonses.com')
          @mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
          ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
          ReverificationTracker.expects(:store_email_for_later_retry).once
          ReverificationTracker.expects(:destroy_account).never
          ReverificationTracker.poll_bounce_queue
        end
      end
    end

    describe 'convert account into spam phase (3rd phase)' do
      describe 'sending the account is spam notification' do
        it 'should retrieve the correct accounts to convert to spam' do
          create_list(:second_phase_account, 2)
          create(:first_phase_account)
          create(:account)
          create(:unverified_account)
          assert_equal 2, ReverificationTracker.second_phase_accounts(5).count
        end

        it "should send the 'account is spam' notification to the correct account when the time is right" do
          correct_account = create(:second_phase_account)
          incorrect_account = create(:first_phase_account)
          incorrect_account_two = create(:unverified_account)
          incorrect_account_three = create(:account)
          account_is_spam_notice = ReverificationTracker.account_is_spam_notice(correct_account.email)
          wrong_notice_one = ReverificationTracker.account_is_spam_notice(incorrect_account.email)
          wrong_notice_two = ReverificationTracker.account_is_spam_notice(incorrect_account_two.email)
          wrong_notice_three = ReverificationTracker.account_is_spam_notice(incorrect_account_three.email)
          ReverificationTracker.expects(:find_account_by_email).with(correct_account.email).returns(correct_account)
          ReverificationTracker.expects(:find_account_by_email).with(incorrect_account).never
          ReverificationTracker.expects(:find_account_by_email).with(incorrect_account_two).never
          ReverificationTracker.expects(:find_account_by_email).with(incorrect_account_three).never
          ReverificationTracker.stubs(:time_is_right?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(account_is_spam_notice).once
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_one).never
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_two).never
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_three).never
          ReverificationTracker.send_account_is_spam_notification
        end

        it "should not send an 'account is spam' notification to an account when the time is premature" do
          incorrect_account = create(:second_phase_account)
          marked_for_spam_notice = ReverificationTracker.marked_for_spam_notice(incorrect_account.email)
          ReverificationTracker.expects(:find_account_by_email).with(incorrect_account.email).returns(incorrect_account)
          ReverificationTracker.stubs(:time_is_right?).returns(false)
          AWS::SimpleEmailService.any_instance.expects(:send_email).never
          ReverificationTracker.send_account_is_spam_notification
        end

        it 'should not send a notification when the ses limit is reached' do
          correct_account = create(:second_phase_account)
          ReverificationTracker.expects(:ses_limit_reached?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_account).never
          ReverificationTracker.send_account_is_spam_notification
        end
      end

      describe 'success scenario' do
        it 'should correctly update the reverification tracker' do
          correct_account = create(:second_phase_account)
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(SuccessMessage.new).once
          ReverificationTracker.stubs(:success_queue).returns(mock_queue)
          Account.expects(:find_by_email).returns(correct_account).once
          # ReverificationTracker.expects(:update_reverification_tracker).with(correct_account)
          ReverificationTracker.expects(:convert_to_spam).with(correct_account)
          ReverificationTracker.poll_success_queue
        end

        it 'should correctly convert the correct account into spam' do
          correct_account = create(:second_phase_account)
          account_is_spam_notice = ReverificationTracker.account_is_spam_notice(correct_account.email)
          ReverificationTracker.expects(:find_account_by_email).returns(correct_account).once
          ReverificationTracker.stubs(:time_is_right?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(account_is_spam_notice).once
          ReverificationTracker.stubs(:convert_to_spam).with(correct_account).returns(correct_account.update(level: -20))
          ReverificationTracker.send_account_is_spam_notification
          assert correct_account.access.spam?
          assert_equal -20, correct_account.level
        end

        it 'should correctly update a reverication trackers fields' do
          past = DateTime.now.utc - 14.days
          recent_update = past + 13.days
          account = create(:second_phase_account, created_at: past, updated_at: recent_update)
          ReverificationTracker.update_reverification_tracker(account)
          assert_equal 'spam', account.reverification_tracker.status
          assert_equal DateTime.now.in_time_zone.to_i, account.reverification_tracker.updated_at.to_i
          assert_not_equal past, account.reverification_tracker.updated_at
        end
      end

      describe 'transient bounce scenario' do
        it 'should send the correct retry email' do
          account = create(:second_phase_account, email: 'ooto@simulator.amazonses.com')
          account_is_spam_notice = ReverificationTracker.account_is_spam_notice(account.email)
          wrong_notice_one = ReverificationTracker.marked_for_spam_notice(account.email)
          wrong_notice_two = ReverificationTracker.first_reverification_notice(account.email)
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
          ReverificationTracker.stubs(:transient_bounce_queue).returns(mock_queue)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(account_is_spam_notice).once
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_one).never
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_two).never
          ReverificationTracker.poll_transient_bounce_queue
        end

        it 'should not resend if the ses limit is reached' do
          correct_account = create(:second_phase_account, email: 'ooto@simulator.amazonses.com')
          ReverificationTracker.expects(:ses_limit_reached?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_account).never
          ReverificationTracker.poll_transient_bounce_queue
        end
      end

      describe 'hard bounce scenario' do
        before do
          @mock_queue = mock('AWS::SQS::Queue::MOCK')
        end

        it 'should delete an account that is a hard permanent bounce' do
          hard_account = create(:second_phase_account, email: 'bounce@simulator.amazonses.com')
          @mock_queue.stubs(:poll).yields(HardBounceMessage.new).once
          ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
          ReverificationTracker.expects(:store_email_for_later_retry).never
          ReverificationTracker.expects(:destroy_account)
          ReverificationTracker.poll_bounce_queue
        end

        it 'should send a soft bounce to the transient bounce queue' do
          transient_account = create(:second_phase_account, email: 'ooto@simulator.amazonses.com')
          @mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
          ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
          ReverificationTracker.expects(:store_email_for_later_retry).once
          ReverificationTracker.expects(:destroy_account).never
          ReverificationTracker.poll_bounce_queue
        end
      end
    end

    describe 'one day left before deletion phase (4th phase)' do
      describe 'sending the one day left before delteion notification' do
        it 'should retrieve the correct accounts to convert to spam' do
          create(:third_phase_spam_account)
          create(:second_phase_account)
          create(:first_phase_account)
          create(:account)
          assert_equal 1, ReverificationTracker.third_phase_accounts(5).count
        end

        it "should send the 'one day left before deletion notice' to the correct account when the time is right" do
          correct_account = create(:third_phase_spam_account)
          incorrect_account = create(:first_phase_account)
          incorrect_account_two = create(:unverified_account)
          incorrect_account_three = create(:account)
          incorrect_account_four = create(:second_phase_account)
          one_day_left_before_deletion_notice = ReverificationTracker.one_day_before_deletion_notice(correct_account.email)
          wrong_notice_one = ReverificationTracker.one_day_before_deletion_notice(incorrect_account.email)
          wrong_notice_two = ReverificationTracker.one_day_before_deletion_notice(incorrect_account_two.email)
          wrong_notice_three = ReverificationTracker.one_day_before_deletion_notice(incorrect_account_three.email)
          wrong_notice_four = ReverificationTracker.one_day_before_deletion_notice(incorrect_account_four.email)
          ReverificationTracker.expects(:find_account_by_email).with(correct_account.email).returns(correct_account)
          ReverificationTracker.expects(:find_account_by_email).with(incorrect_account).never
          ReverificationTracker.expects(:find_account_by_email).with(incorrect_account_two).never
          ReverificationTracker.expects(:find_account_by_email).with(incorrect_account_three).never
          ReverificationTracker.stubs(:time_is_right?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(one_day_left_before_deletion_notice).once
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_one).never
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_two).never
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_three).never
          ReverificationTracker.send_one_day_left_before_deletion_notification
        end

        it "should not send a 'one day left before deletion notice' to an account when the time is premature" do
          incorrect_account = create(:third_phase_spam_account)
          ReverificationTracker.expects(:find_account_by_email).with(incorrect_account.email).returns(incorrect_account)
          ReverificationTracker.stubs(:time_is_right?).returns(false)
          AWS::SimpleEmailService.any_instance.expects(:send_email).never
          ReverificationTracker.send_one_day_left_before_deletion_notification
        end

        it 'should not send an notification when the ses limit is reached' do
          correct_account = create(:third_phase_spam_account)
          ReverificationTracker.expects(:ses_limit_reached?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_account).never
          ReverificationTracker.send_one_day_left_before_deletion_notification
        end
      end

      describe 'success scenario' do
         it 'should correctly update the reverification tracker' do
          correct_account = create(:third_phase_spam_account)
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(SuccessMessage.new).once
          ReverificationTracker.stubs(:success_queue).returns(mock_queue)
          Account.expects(:find_by_email).returns(correct_account).once
          ReverificationTracker.expects(:update_reverification_tracker).with(correct_account)
          ReverificationTracker.expects(:convert_to_spam).with(correct_account).never
          ReverificationTracker.poll_success_queue
        end
        
        it 'should correctly update a reverication trackers fields' do
          past = DateTime.now.utc - 14.days
          recent_update = past + 13.days
          account = create(:third_phase_spam_account, created_at: past, updated_at: recent_update)
          ReverificationTracker.update_reverification_tracker(account)
          assert_equal 'final warning', account.reverification_tracker.status
          assert_equal DateTime.now.in_time_zone.to_i, account.reverification_tracker.updated_at.to_i
          assert_not_equal past, account.reverification_tracker.updated_at
        end
      end

      describe 'transient bounce scenario' do
         it 'should send the correct retry email' do
          account = create(:third_phase_spam_account, email: 'ooto@simulator.amazonses.com')
          one_day_before_deletion_notice = ReverificationTracker.one_day_before_deletion_notice(account.email)
          wrong_notice_one = ReverificationTracker.account_is_spam_notice(account.email)
          wrong_notice_two = ReverificationTracker.marked_for_spam_notice(account.email)
          wrong_notice_three = ReverificationTracker.first_reverification_notice(account.email)
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
          ReverificationTracker.stubs(:transient_bounce_queue).returns(mock_queue)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(one_day_before_deletion_notice).once
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_one).never
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_two).never
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_three).never
          ReverificationTracker.poll_transient_bounce_queue
        end

        it 'should not resend if the ses limit is reached' do
          correct_account = create(:third_phase_spam_account, email: 'ooto@simulator.amazonses.com')
          ReverificationTracker.expects(:ses_limit_reached?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_account).never
          ReverificationTracker.poll_transient_bounce_queue
        end
      end

      describe 'hard bounce scenario' do
        before do
          @mock_queue = mock('AWS::SQS::Queue::MOCK')
        end

        it 'should delete an account that is a hard permanent bounce' do
          hard_account = create(:third_phase_spam_account, email: 'bounce@simulator.amazonses.com')
          @mock_queue.stubs(:poll).yields(HardBounceMessage.new).once
          ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
          ReverificationTracker.expects(:store_email_for_later_retry).never
          ReverificationTracker.expects(:destroy_account)
          ReverificationTracker.poll_bounce_queue
        end

        it 'should send a soft bounce to the transient bounce queue' do
          transient_account = create(:third_phase_spam_account, email: 'ooto@simulator.amazonses.com')
          @mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
          ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
          ReverificationTracker.expects(:store_email_for_later_retry).once
          ReverificationTracker.expects(:destroy_account).never
          ReverificationTracker.poll_bounce_queue
        end
      end
    end
  end
end 
