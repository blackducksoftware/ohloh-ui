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

  # Note: 
  # unverified_account has no verifications association nor an reverification_tracker association

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

        it "should create a reverification tracker with 'initial' status" do
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

    # describe 'marked as spam phase' do

    #   describe 'accounts with initial notice' do
    #     it 'should grab accounts that only have an initial notice' do
    #       create_list(:account_with_an_initial_notification_and_no_verifications, 3)
    #       # The account below has no initial notice
    #       create_list(:unverified_account, 2)
    #       assert_equal 3, ReverificationTracker.accounts_with_initial_notice(5).count
    #     end
    #   end

    #   it "should send a 'marked for spam' notification to the correct accounts 13 days from initial notice" do
    #     correct_account = create(:account_with_an_initial_notification_and_no_verifications)
    #     correct_account_ar = correct_account.reverification_tracker
    #     account_without_initial_notice = create(:unverified_account)
    #     verified_account = create(:account)
    #     ReverificationTracker.stubs(:time_is_right?).returns(true)
    #     AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.marked_for_spam_notice(correct_account.email)).once
    #     AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.marked_for_spam_notice(account_without_initial_notice.email)).never
    #     AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.marked_for_spam_notice(verified_account.email)).never
    #     AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.first_reverification_notice(correct_account.email)).never
    #     AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.first_reverification_notice(verified_account.email)).never
    #     AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.marked_for_spam_notice(verified_account.email)).never
    #     ReverificationTracker.send_marked_for_spam_notification
    #   end

    #   it "should not send a 'marked for spam' notification to accounts if the time is incorrect" do
    #     correct_account = create(:account_with_an_initial_notification_and_no_verifications)
    #     correct_account_ar = correct_account.reverification_tracker
    #     account_without_initial_notice = create(:unverified_account)
    #     verified_account = create(:account)
    #     ReverificationTracker.stubs(:time_is_right?).returns(false)
    #     AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.marked_for_spam_notice(correct_account.email)).never
    #     AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.marked_for_spam_notice(account_without_initial_notice.email)).never
    #     AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.marked_for_spam_notice(verified_account.email)).never
    #     AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.first_reverification_notice(correct_account.email)).never
    #     AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.first_reverification_notice(verified_account.email)).never
    #     AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.marked_for_spam_notice(verified_account.email)).never
    #     ReverificationTracker.send_marked_for_spam_notification
    #   end

    #   it 'should not send an email if max quota has been met' do
    #     account = create(:account_with_an_initial_notification_and_no_verifications)
    #     create(:unverified_account)
    #     ReverificationTracker.expects(:ses_limit_reached?).returns(true)
    #     AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.marked_for_spam_notice(account.email)).never
    #     ReverificationTracker.send_marked_for_spam_notification
    #   end

    #   describe "process for a successful 'marked as spam' delivery" do
    #     it "should test the process of correctly updating an account's account_reverification status and updated_at attributes" do
    #       account = create(:account_with_an_initial_notification_and_no_verifications)
    #       updated_account_reverification = account.reverification_tracker.updated_at + 13.days
    #       mock_queue = mock('AWS::SQS::Queue::MOCK')
    #       mock_queue.stubs(:poll).yields(SuccessMessage.new).once
    #       ReverificationTracker.stubs(:success_queue).returns(mock_queue)
    #       Account.expects(:find_by_email).returns(account).once
    #       ReverificationTracker.expects(:update_account_reverification).with(account).returns(updated_account_reverification)
    #       ReverificationTracker.poll_success_queue
    #     end

    #     it 'should test the update_reverification method' do
    #       past = DateTime.now.utc - 13.days
    #       account = create(:account_with_an_initial_notification_and_no_verifications, created_at: past, updated_at: past)
    #       ReverificationTracker.update_account_reverification(account)
    #       assert_equal 'marked for spam', account.reverification_tracker.status
    #       assert_equal DateTime.now.in_time_zone.to_i, account.reverification_tracker.updated_at.to_i
    #       assert_not_equal past, account.reverification_tracker.updated_at
    #     end
    #   end

    #   describe "process for transient bounces with 'marked for spam' deliveries" do
    #     it "should resend the correct retry email for 'marked as spam' deliveries" do
    #       account = create(:account_with_an_initial_notification_and_no_verifications, email: 'ooto@simulator.amazonses.com')
    #       mock_queue = mock('AWS::SQS::Queue::MOCK')
    #       mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
    #       ReverificationTracker.stubs(:transient_bounce_queue).returns(mock_queue)
    #       AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.marked_for_spam_notice(account.email)).once
    #       AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.first_reverification_notice(account.email)).never
    #       ReverificationTracker.poll_transient_bounce_queue
    #     end
    #   end
    # end

    # describe 'convert account into spam phase' do
    #   it 'should grab the correct accounts to mark as spam' do
    #     create_list(:account_with_a_marked_for_spam_notification_and_no_verifications, 3)
    #     create(:account_with_an_initial_notification_and_no_verifications)
    #     create(:account)
    #     assert_equal 3, ReverificationTracker.accounts_with_a_marked_for_spam_notice(5).count
    #   end

    #   # describe 'time_is_right?' do
    #   #   it 'should correctly determine if an account should be converted to spam or not' do
    #   #   end
    #   # end

    #   describe 'account conversion' do
    #     it 'should correctly convert the correct account into spam' do
    #       correct_account = create(:account_with_a_marked_for_spam_notification_and_no_verifications)
    #       ReverificationTracker.expects(:find_account_by_email).returns(correct_account).once
    #       ReverificationTracker.stubs(:time_is_right?).returns(true)
    #       AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.account_is_spam_notice(correct_account.email)).once
    #       ReverificationTracker.stubs(:convert_to_spam).with(correct_account).returns(correct_account.update(level: -20))
    #       ReverificationTracker.send_account_is_spam_notification
    #       assert correct_account.access.spam?
    #       assert_equal -20, correct_account.level
    #     end
    #   end

    #   describe 'sending notifications' do
    #     it 'should not send emails if ses limit is reached' do
    #       ReverificationTracker.expects(:ses_limit_reached?).returns(true)
    #       AWS::SimpleEmailService.any_instance.expects(:send_email).never
    #       ReverificationTracker.send_account_is_spam_notification
    #     end

    #     it "should send an 'account is spam' notification to the correct account" do
    #       correct_account = create(:account_with_a_marked_for_spam_notification_and_no_verifications)
    #       account_with_initial_notice = create(:account_with_an_initial_notification_and_no_verifications)
    #       account_without_initial_notice = create(:unverified_account)
    #       verified_account = create(:account)
    #       ReverificationTracker.stubs(:time_is_right?).returns(true)
    #       AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.account_is_spam_notice(correct_account.email)).once
    #       AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.account_is_spam_notice(account_without_initial_notice.email)).never
    #       AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.account_is_spam_notice(account_with_initial_notice.email)).never
    #       ReverificationTracker.send_account_is_spam_notification
    #     end

    #     it 'should not send an account is spam notifice to a premature account' do
    #       correct_account = create(:account_with_a_marked_for_spam_notification_and_no_verifications)
    #       ReverificationTracker.stubs(:time_is_right?).returns(false)
    #       AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.account_is_spam_notice(correct_account.email)).never
    #       ReverificationTracker.send_account_is_spam_notification
    #     end

    #     describe 'success' do
    #       it 'should update an account reverifications updated_at' do
    #         account = create(:account_with_a_marked_for_spam_notification_and_no_verifications)
    #         updated_account_reverification = account.reverification_tracker.updated_at + 14.days
    #         mock_queue = mock('AWS::SQS::Queue::MOCK')
    #         mock_queue.stubs(:poll).yields(SuccessMessage.new).once
    #         ReverificationTracker.stubs(:success_queue).returns(mock_queue)
    #         Account.expects(:find_by_email).returns(account).once
    #         ReverificationTracker.expects(:update_account_reverification).with(account).returns(updated_account_reverification)
    #         ReverificationTracker.poll_success_queue
    #       end

    #       it 'should test the update_reverification method' do
    #         past = DateTime.now.utc - 14.days
    #         account = create(:account_with_a_marked_for_spam_notification_and_no_verifications, created_at: past)
    #         ReverificationTracker.update_account_reverification(account)
    #         assert_equal 'spam', account.reverification_tracker.status
    #         assert_equal DateTime.now.in_time_zone.to_i, account.reverification_tracker.updated_at.to_i
    #         assert_not_equal past, account.reverification_tracker.updated_at
    #       end
    #     end

    #     describe 'transient' do
    #       it 'should send the correct retry email' do
    #         account = create(:account_with_a_marked_for_spam_notification_and_no_verifications, email: 'ooto@simulator.amazonses.com')
    #         mock_queue = mock('AWS::SQS::Queue::MOCK')
    #         mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
    #         ReverificationTracker.stubs(:transient_bounce_queue).returns(mock_queue)
    #         AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.account_is_spam_notice(account.email)).once
    #         AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.marked_for_spam_notice(account.email)).never
    #         AWS::SimpleEmailService.any_instance.expects(:send_email).with(ReverificationTracker.first_reverification_notice(account.email)).never
    #         ReverificationTracker.poll_transient_bounce_queue
    #       end
    #     end
    #   end
    end
  end
end
