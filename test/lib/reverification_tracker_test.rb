require 'test_helper'

class ReverificationTrackerTest < ActiveSupport::TestCase
  class HardBounceBody
    def body_message_as_h
      { 'bounce': { 'bounceType': 'Permanent',
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

  class SuccessBody
    def body_message_as_h
      { 'delivery':
          { 'recipients': ['success@simulator.amazonses.com'] }
      }.with_indifferent_access
    end
  end

  class SuccessMessage
    def as_sns_message
      SuccessBody.new
    end
  end

  class TransientBounceBody
     def body_message_as_h
       { 'bounce': { 'bounceType': 'Transient',
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

  describe 'ReverificationTracker' do
    describe 'first notification phase' do
      describe 'sending the first notification' do
        it 'should only select accounts that have not verified' do
          create(:unverified_account, :success)
          create(:unverified_account, :complaint)
          create(:unverified_account, :hard_bounce)
          create(:unverified_account, :soft_bounce)
          create(:account)
          assert_equal 4, Account.unverified_accounts(5).count
          assert_not_equal Account.count, Account.unverified_accounts(5).count
        end

        it 'should only send notifications to accounts that do not have verifications only' do
          correct_account = create(:unverified_account, :success)
          create_list(:account, 4)
          first_notice = ReverificationTracker.first_reverification_notice(correct_account.email)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(first_notice).once
          ReverificationTracker.expects(:create_reverification_tracker)
          ReverificationTracker.send_first_notification
        end

        it 'it should immediately create a rev_tracker with status pending after notice is sent' do
          message_id = { message_id: "d377dd-93-4a-884382d-000000" }.with_indifferent_access
          correct_account = create(:unverified_account, :success)
          assert_difference 'ReverificationTracker.count', 1 do
             ReverificationTracker.create_reverification_tracker(correct_account, message_id)
             assert ReverificationTracker.first.pending?
             assert ReverificationTracker.first.initial?
          end
        end

        it 'should not resend if the ses limit is reached' do
           ReverificationTracker.expects(:ses_limit_reached?).returns(true)
           AWS::SimpleEmailService.any_instance.expects(:send_email).never
           ReverificationTracker.send_first_notification
        end
      end

      describe 'success scenario' do
        before do
           @rev_tracker = create(:reverification_tracker)
           mock_queue = mock('AWS::SQS::Queue::MOCK')
           mock_queue.stubs(:poll).yields(SuccessMessage.new).once
           ReverificationTracker.stubs(:success_queue).returns(mock_queue)
        end

        it "should update an account's rev_tracker to delivered" do
           Account.expects(:find_by_email).returns(@rev_tracker.account).once
           ReverificationTracker.any_instance.expects(:pending?).returns(true)
           ReverificationTracker.any_instance.expects(:delivered!)
           ReverificationTracker.poll_success_queue
        end

        it "should not update an account's rev_tracker to delivered if pending is false" do
           Account.expects(:find_by_email).returns(@rev_tracker.account).once
           ReverificationTracker.any_instance.expects(:pending?).returns(false)
           ReverificationTracker.any_instance.expects(:delivered!).never
           ReverificationTracker.poll_success_queue
        end
      end

      # Note: Remember these emails get send to success queue AND transient queue
      describe 'transient bounce scenario' do
        before do
          @transient_account = create(:initial_phase_account, email: 'ooto@simulator.amazonses.com')
          @first_notice = ReverificationTracker.first_reverification_notice(@transient_account.email)
        end
 
        it 'should retry the first reverification notice' do
            mock_queue = mock('AWS::SQS::Queue::MOCK')
            mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
            ReverificationTracker.stubs(:transient_bounce_queue).returns(mock_queue)
            ReverificationTracker.stubs(:transient_bounce_queue).returns(mock_queue)
            ReverificationTracker.any_instance.expects(:send_mail).with(@first_notice).once
            ReverificationTracker.poll_transient_bounce_queue
        end

        it ' should specify that an ooto triggered an auto response' do
        end
 
        it 'should not resend if the ses limit is reached' do
           ReverificationTracker.expects(:ses_limit_reached?).returns(true)
           ReverificationTracker.any_instance.expects(:send_mail).with(@first_notcie).never
           ReverificationTracker.poll_transient_bounce_queue
        end
      end
    end
  end
end 

 #       describe 'hard bounce scenario' do
 #         before do
 #           @hard_account = create(:unverified_account, :hard_bounce)
 #           @mock_queue = mock('AWS::SQS::Queue::MOCK')
 #         end

 #         it 'should delete any account that is a hard permanent bounce' do
 #           @mock_queue.stubs(:poll).yields(HardBounceMessage.new).once
 #           ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
 #           ReverificationTracker.expects(:store_email_for_later_retry).never
 #           ReverificationTracker.expects(:destroy_account)
 #           ReverificationTracker.poll_bounce_queue
 #         end

 #         it 'should send a soft bounce to the transient bounce queue' do
 #           @mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
 #           ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
 #           ReverificationTracker.expects(:store_email_for_later_retry).once
 #           ReverificationTracker.expects(:destroy_account).never
 #           ReverificationTracker.poll_bounce_queue
 #         end
 #       end
 #     end

 #     describe 'mark as spam phase (2nd phase)' do
 #       describe 'sending the marked for spam notification' do
 #         it 'should retrieve accounts that only received the first notice' do
 #           create_list(:initial_phase_account, 3)
 #           create(:unverified_account)
 #           create(:account)
 #           assert_equal 3, ReverificationTracker.initial_phase_accounts(5).count
 #         end

 #         it "should send a 'marked for spam' notification to the correct account when the time is right" do
 #           account = create(:initial_phase_account)
 #           unverified_account = create(:unverified_account)
 #           verified_account = create(:account)
 #           marked_for_spam_notice = ReverificationTracker.marked_for_spam_notice(account.email)
 #           wrong_notice_one = ReverificationTracker.marked_for_spam_notice(unverified_account.email)
 #           wrong_notice_two = ReverificationTracker.marked_for_spam_notice(verified_account.email)
 #           ReverificationTracker.stubs(:time_is_right?).returns(true)
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(marked_for_spam_notice).once
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_one).never
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_two).never
 #           ReverificationTracker.send_marked_for_spam_notification
 #         end

 #         it "should not send a 'marked for spam' notification to any account when the time is premature" do
 #           ReverificationTracker.stubs(:time_is_right?).returns(false)
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).never
 #           ReverificationTracker.send_marked_for_spam_notification
 #         end

 #         it 'should not send an account when the ses limit is reached' do
 #           correct_account = create(:initial_phase_account)
 #           ReverificationTracker.expects(:ses_limit_reached?).returns(true)
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_account).never
 #           ReverificationTracker.send_marked_for_spam_notification
 #         end
 #       end

 #       describe 'success scenario' do
 #         it 'should expect to correctly update the reverification tracker status and updated_at' do
 #           account = create(:initial_phase_account, email: 'success@simulator.amazonses.com')
 #           mock_queue = mock('AWS::SQS::Queue::MOCK')
 #           mock_queue.stubs(:poll).yields(SuccessMessage.new).once
 #           ReverificationTracker.stubs(:success_queue).returns(mock_queue)
 #           ReverificationTracker.expects(:update_reverification_tracker).with(account)
 #           ReverificationTracker.poll_success_queue
 #         end

 #         it 'should update a reverification tracker with marked for spam and current time' do
 #           past = DateTime.now.utc - 13.days
 #           account = create(:initial_phase_account, created_at: past, updated_at: past)
 #           ReverificationTracker.update_reverification_tracker(account)
 #           assert account.reverification_tracker.marked_for_spam?
 #           assert_equal DateTime.now.in_time_zone.to_i, account.reverification_tracker.updated_at.to_i
 #           assert_not_equal past, account.reverification_tracker.updated_at
 #         end
 #       end

 #       describe 'transient bounce scenario' do
 #         it 'should retry the correct email' do
 #           correct_account = create(:initial_phase_account, email: 'ooto@simulator.amazonses.com')
 #           incorrect_account = create(:unverified_account)
 #           mock_queue = mock('AWS::SQS::Queue::MOCK')
 #           mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
 #           correct_notice = ReverificationTracker.marked_for_spam_notice(correct_account.email)
 #           incorrect_notice = ReverificationTracker.marked_for_spam_notice(incorrect_account.email)
 #           ReverificationTracker.stubs(:transient_bounce_queue).returns(mock_queue)
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_notice).once
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(incorrect_notice).never
 #           ReverificationTracker.poll_transient_bounce_queue
 #         end

 #         it 'should not resend if the ses limit is reached' do
 #           correct_account = create(:initial_phase_account, email: 'ooto@simulator.amazonses.com')
 #           ReverificationTracker.expects(:ses_limit_reached?).returns(true)
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_account).never
 #           ReverificationTracker.poll_transient_bounce_queue
 #         end
 #       end

 #       describe 'hard bounce scenario' do
 #         before do
 #           @mock_queue = mock('AWS::SQS::Queue::MOCK')
 #         end

 #         it 'should delete an account that is a hard permanent bounce' do
 #           @mock_queue.stubs(:poll).yields(HardBounceMessage.new).once
 #           ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
 #           ReverificationTracker.expects(:store_email_for_later_retry).never
 #           ReverificationTracker.expects(:destroy_account)
 #           ReverificationTracker.poll_bounce_queue
 #         end


 #         it 'should send a soft bounce to the transient bounce queue' do
 #           @mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
 #           ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
 #           ReverificationTracker.expects(:store_email_for_later_retry).once
 #           ReverificationTracker.expects(:destroy_account).never
 #           ReverificationTracker.poll_bounce_queue
 #         end
 #       end
 #     end

 #     describe 'convert account into spam phase (3rd phase)' do
 #       describe 'sending the account is spam notification' do
 #         it 'should retrieve the correct accounts to convert to spam' do
 #           create_list(:marked_for_spam_phase_account, 2)
 #           create(:initial_phase_account)
 #           create(:account)
 #           create(:unverified_account)
 #           assert_equal 2, ReverificationTracker.marked_for_spam_phase_accounts(5).count
 #         end

 #         it "should send the 'account is spam' notification to the correct account when the time is right" do
 #           correct_account = create(:marked_for_spam_phase_account)
 #           incorrect_account = create(:initial_phase_account)
 #           incorrect_account_two = create(:unverified_account)
 #           incorrect_account_three = create(:account)
 #           account_is_spam_notice = ReverificationTracker.account_is_spam_notice(correct_account.email)
 #           wrong_notice_one = ReverificationTracker.account_is_spam_notice(incorrect_account.email)
 #           wrong_notice_two = ReverificationTracker.account_is_spam_notice(incorrect_account_two.email)
 #           wrong_notice_three = ReverificationTracker.account_is_spam_notice(incorrect_account_three.email)
 #           ReverificationTracker.stubs(:time_is_right?).returns(true)
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(account_is_spam_notice).once
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_one).never
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_two).never
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_three).never
 #           ReverificationTracker.send_account_is_spam_notification
 #         end

 #         it "should not send an 'account is spam' notification to an account when the time is premature" do
 #           ReverificationTracker.stubs(:time_is_right?).returns(false)
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).never
 #           ReverificationTracker.send_account_is_spam_notification
 #         end

 #         it 'should not send a notification when the ses limit is reached' do
 #           correct_account = create(:marked_for_spam_phase_account)
 #           ReverificationTracker.expects(:ses_limit_reached?).returns(true)
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_account).never
 #           ReverificationTracker.send_account_is_spam_notification
 #         end
 #       end

 #       describe 'success scenario' do
 #         it 'should correctly update the reverification tracker' do
 #           correct_account = create(:marked_for_spam_phase_account, email: 'success@simulator.amazonses.com')
 #           mock_queue = mock('AWS::SQS::Queue::MOCK')
 #           mock_queue.stubs(:poll).yields(SuccessMessage.new).once
 #           ReverificationTracker.stubs(:success_queue).returns(mock_queue)
 #           ReverificationTracker.expects(:update_reverification_tracker).with(correct_account)
 #           ReverificationTracker.poll_success_queue
 #         end

 #         it 'should correctly update a reverication trackers fields' do
 #           past = DateTime.now.utc - 14.days
 #           recent_update = past + 13.days
 #           account = create(:marked_for_spam_phase_account, created_at: past, updated_at: recent_update)
 #           ReverificationTracker.update_reverification_tracker(account)
 #           assert account.reverification_tracker.spam?
 #           assert_equal 0 - 20, account.level
 #           assert_equal DateTime.now.in_time_zone.to_i, account.reverification_tracker.updated_at.to_i
 #           assert_not_equal past, account.reverification_tracker.updated_at
 #         end
      
 #       describe 'transient bounce scenario' do
 #         it 'should send the correct retry email' do
 #           account = create(:marked_for_spam_phase_account, email: 'ooto@simulator.amazonses.com')
 #           account_is_spam_notice = ReverificationTracker.account_is_spam_notice(account.email)
 #           wrong_notice_one = ReverificationTracker.marked_for_spam_notice(account.email)
 #           wrong_notice_two = ReverificationTracker.first_reverification_notice(account.email)
 #           mock_queue = mock('AWS::SQS::Queue::MOCK')
 #           mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
 #           ReverificationTracker.stubs(:transient_bounce_queue).returns(mock_queue)
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(account_is_spam_notice).once
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_one).never
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_two).never
 #           ReverificationTracker.poll_transient_bounce_queue
 #         end
 
 #         it 'should not resend if the ses limit is reached' do
 #           correct_account = create(:marked_for_spam_phase_account, email: 'ooto@simulator.amazonses.com')
 #           ReverificationTracker.expects(:ses_limit_reached?).returns(true)
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_account).never
 #           ReverificationTracker.poll_transient_bounce_queue
 #         end
 #       end

 #       describe 'hard bounce scenario' do
 #         before do
 #           @mock_queue = mock('AWS::SQS::Queue::MOCK')
 #         end

 #         it 'should delete an account that is a hard permanent bounce' do
 #           @mock_queue.stubs(:poll).yields(HardBounceMessage.new).once
 #           ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
 #           ReverificationTracker.expects(:store_email_for_later_retry).never
 #           ReverificationTracker.expects(:destroy_account)
 #           ReverificationTracker.poll_bounce_queue
 #         end

 #         it 'should send a soft bounce to the transient bounce queue' do
 #           @mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
 #           ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
 #           ReverificationTracker.expects(:store_email_for_later_retry).once
 #           ReverificationTracker.expects(:destroy_account).never
 #           ReverificationTracker.poll_bounce_queue
 #         end
 #       end
 #     end

 #     describe 'one day left before deletion phase (4th phase)' do
 #       describe 'sending the one day left before delteion notification' do
 #         it 'should retrieve the correct accounts to convert to spam' do
 #           create(:spam_phase_account)
 #           create(:marked_for_spam_phase_account)
 #           create(:initial_phase_account)
 #           create(:account)
 #           assert_equal 1, ReverificationTracker.spam_phase_accounts(5).count
 #         end

 #         it "should send the 'one day left before deletion notice' to the correct account when the time is right" do
 #           correct_account = create(:spam_phase_account)
 #           incorrect_account = create(:initial_phase_account)
 #           incorrect_account_two = create(:unverified_account)
 #           incorrect_account_three = create(:account)
 #           incorrect_account_four = create(:marked_for_spam_phase_account)
 #           one_day_left_before_deletion = ReverificationTracker.one_day_before_deletion_notice(correct_account.email)
 #           wrong_notice_one = ReverificationTracker.one_day_before_deletion_notice(incorrect_account.email)
 #           wrong_notice_two = ReverificationTracker.one_day_before_deletion_notice(incorrect_account_two.email)
 #           wrong_notice_three = ReverificationTracker.one_day_before_deletion_notice(incorrect_account_three.email)
 #           wrong_notice_four = ReverificationTracker.one_day_before_deletion_notice(incorrect_account_four.email)
 #           ReverificationTracker.stubs(:time_is_right?).returns(true)
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(one_day_left_before_deletion).once
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_one).never
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_two).never
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_three).never
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_four).never
 #           ReverificationTracker.send_one_day_left_before_deletion_notification
 #         end

 #         it "should not send a 'one day left before deletion notice' to an account when the time is premature" do
 #           ReverificationTracker.stubs(:time_is_right?).returns(false)
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).never
 #           ReverificationTracker.send_one_day_left_before_deletion_notification
 #         end

 #         it 'should not send an notification when the ses limit is reached' do
 #           correct_account = create(:spam_phase_account)
 #           ReverificationTracker.expects(:ses_limit_reached?).returns(true)
 #           AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_account).never
 #           ReverificationTracker.send_one_day_left_before_deletion_notification
 #         end
 #       end

 #       describe 'success scenario' do
 #         it 'should correctly update the reverification tracker' do
 #           correct_account = create(:spam_phase_account, email: 'success@simulator.amazonses.com')
 #           mock_queue = mock('AWS::SQS::Queue::MOCK')
 #           mock_queue.stubs(:poll).yields(SuccessMessage.new).once
 #           ReverificationTracker.stubs(:success_queue).returns(mock_queue)
 #           ReverificationTracker.expects(:update_reverification_tracker).with(correct_account)
 #           ReverificationTracker.expects(:convert_to_spam).with(correct_account).never
 #           ReverificationTracker.poll_success_queue
 #         end

 #         it 'should correctly update a reverication trackers fields' do
 #           past = DateTime.now.utc - 14.days
 #           recent_update = past + 13.days
 #           account = create(:spam_phase_account, created_at: past, updated_at: recent_update)
 #           ReverificationTracker.update_reverification_tracker(account)
 #           assert account.reverification_tracker.final_warning?
 #           assert_equal DateTime.now.in_time_zone.to_i, account.reverification_tracker.updated_at.to_i
 #           assert_not_equal past, account.reverification_tracker.updated_at
 #         end
 #       end

 #       describe 'transient bounce scenario' do
 #          it 'should send the correct retry email' do
 #            account = create(:spam_phase_account, email: 'ooto@simulator.amazonses.com')
 #            one_day_before_deletion_notice = ReverificationTracker.one_day_before_deletion_notice(account.email)
 #            wrong_notice_one = ReverificationTracker.account_is_spam_notice(account.email)
 #            wrong_notice_two = ReverificationTracker.marked_for_spam_notice(account.email)
 #            wrong_notice_three = ReverificationTracker.first_reverification_notice(account.email)
 #            mock_queue = mock('AWS::SQS::Queue::MOCK')
 #            mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
 #            ReverificationTracker.stubs(:transient_bounce_queue).returns(mock_queue)
 #            AWS::SimpleEmailService.any_instance.expects(:send_email).with(one_day_before_deletion_notice).once
 #            AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_one).never
 #            AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_two).never
 #            AWS::SimpleEmailService.any_instance.expects(:send_email).with(wrong_notice_three).never
 #            ReverificationTracker.poll_transient_bounce_queue
 #          end
 
 #          it 'should not resend if the ses limit is reached' do
 #            correct_account = create(:spam_phase_account, email: 'ooto@simulator.amazonses.com')
 #            ReverificationTracker.expects(:ses_limit_reached?).returns(true)
 #            AWS::SimpleEmailService.any_instance.expects(:send_email).with(correct_account).never
 #            ReverificationTracker.poll_transient_bounce_queue
 #          end
 #        end

 #       describe 'hard bounce scenario' do
 #         before do
 #           @mock_queue = mock('AWS::SQS::Queue::MOCK')
 #         end

 #         it 'should delete an account that is a hard permanent bounce' do
 #           @mock_queue.stubs(:poll).yields(HardBounceMessage.new).once
 #           ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
 #           ReverificationTracker.expects(:store_email_for_later_retry).never
 #           ReverificationTracker.expects(:destroy_account)
 #           ReverificationTracker.poll_bounce_queue
 #         end

 #         it 'should send a soft bounce to the transient bounce queue' do
 #            @mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
 #            ReverificationTracker.stubs(:bounce_queue).returns(@mock_queue)
 #            ReverificationTracker.expects(:store_email_for_later_retry).once
 #            ReverificationTracker.expects(:destroy_account).never
 #            ReverificationTracker.poll_bounce_queue
 #         end
 #       end
 #     end

 #     describe 'delete accounts phase' do
 #       it 'should delete accounts that have reached the point of no return' do
 #         create_list(:account, 5)
 #         create_list(:unverified_account, 5)
 #         create_list(:initial_phase_account, 5)
 #         create_list(:marked_for_spam_phase_account, 5)
 #         create_list(:spam_phase_account, 5)
 #         create_list(:final_warning_phase_account, 5)
 #         ReverificationTracker.where(status: 'final warning').each do |rv|
 #           rv.update(updated_at: rv.created_at + 21.days)
 #         end
 #         ReverificationTracker.delete_unverified_spam_accounts
 #         assert 26, Account.count
 #       end
 #     end

 #     describe 'remove reverification tracker for validated accounts' do
 #       it 'should remove a reverification tracker when an account reverifies' do
 #         create(:validated_account_with_left_over_tracker)
 #         create_list(:final_warning_phase_account, 5)
 #         create_list(:spam_phase_account, 5)
 #         create_list(:marked_for_spam_phase_account, 5)
 #         create_list(:initial_phase_account, 5)
 #         assert_difference 'ReverificationTracker.count', -1 do
 #           ReverificationTracker.remove_reverification_tracker_for_validated_accounts
 #         end
 #       end
 #     end

 #     describe 'time_is_right' do
 #       it 'should without a doubt be absolutely correct for initial accounts' do
 #         account = create(:initial_phase_account)
 #         Timecop.freeze(Time.now + 13.days) do
 #           assert ReverificationTracker.time_is_right?(account.reverification_tracker)
 #         end
 #         Timecop.freeze(Time.now + 1.days) do
 #           assert_not ReverificationTracker.time_is_right?(account.reverification_tracker)
 #         end
 #         Timecop.freeze(Time.now + 2.days) do
 #           assert_not ReverificationTracker.time_is_right?(account.reverification_tracker)
 #         end
 #          Timecop.freeze(Time.now + 3.days) do
 #           assert_not ReverificationTracker.time_is_right?(account.reverification_tracker)
 #         end
 #         Timecop.freeze(Time.now + 4.days) do
 #           assert_not ReverificationTracker.time_is_right?(account.reverification_tracker)
 #         end
 #         Timecop.freeze(Time.now + 5.days) do
 #           assert_not ReverificationTracker.time_is_right?(account.reverification_tracker)
 #         end
 #          Timecop.freeze(Time.now + 6.days) do
 #           assert_not ReverificationTracker.time_is_right?(account.reverification_tracker)
 #         end
 #         Timecop.freeze(Time.now + 7.days) do
 #           assert_not ReverificationTracker.time_is_right?(account.reverification_tracker)
 #         end
 #          Timecop.freeze(Time.now + 8.days) do
 #           assert_not ReverificationTracker.time_is_right?(account.reverification_tracker)
 #         end
 #         Timecop.freeze(Time.now + 9.days) do
 #           assert_not ReverificationTracker.time_is_right?(account.reverification_tracker)
 #         end
 #         Timecop.freeze(Time.now + 10.days) do
 #           assert_not ReverificationTracker.time_is_right?(account.reverification_tracker)
 #         end
 #         Timecop.freeze(Time.now + 11.days) do
 #           assert_not ReverificationTracker.time_is_right?(account.reverification_tracker)
 #         end
 #         Timecop.freeze(Time.now + 12.days) do
 #           assert_not ReverificationTracker.time_is_right?(account.reverification_tracker)
 #         end
 #       end

 #       it 'should without a doubt be absolutely correct for marked as spam accounts' do
 #         account = create(:marked_for_spam_phase_account)
 #         account.reverification_tracker.updated_at = Timecop.travel(account.created_at + 13.days)
 #         assert ReverificationTracker.time_is_right?(account.reverification_tracker)
 #       end

 #       it 'should without a doubt be absolutely correct for final warning accounts' do
 #         account = create(:spam_phase_account)
 #       end
 #     end
 #   end
 # end
