require 'test_helper'

class AccountReverificationTest < ActiveSupport::TestCase

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

  describe 'AccountReverification' do
    describe 'initial notification phase' do
      it 'should only select accounts that have no verifications' do
        create(:account_without_verifications, :success)
        create(:account_without_verifications, :complaint)
        create(:account_without_verifications, :hard_bounce)
        create(:account_without_verifications, :soft_bounce)
        create(:account)
        assert_equal 4, AccountReverification.accounts_without_verifications(5).count
        assert_not_equal Account.count, AccountReverification.accounts_without_verifications(5).count
      end

      it 'should only send notifications to accounts that do not have verifications only' do
        account_w_verification = create(:account)
        create_list(:account_without_verifications, 4)
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(account_w_verification.email)).never
        AWS::SimpleEmailService.any_instance.expects(:send_email).times(4)
        AccountReverification.send_first_notification
      end

      it 'an account should receive only the first reverification notice' do
        account = create(:account_without_verifications, :success)
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(account.email)).once
        AccountReverification.expects(:destroy_account).with(account.email).never
        AccountReverification.expects(:store_email_for_later_retry).with(account).never
        AccountReverification.send_first_notification
      end

      it 'should not send an email if max quota has been met' do
        account = create(:account_without_verifications, :success)
        AccountReverification.expects(:ses_limit_reached?).returns(true)
        AWS::SimpleEmailService.any_instance.expects(:send_email).never
        AccountReverification.send_first_notification
      end

      describe 'success scenario' do
        before do
          @success_account = create(:account_without_verifications, :success)
        end

        it 'should create an associated account reverification with status set to initial' do
          AccountReverification.create_account_reverification(@success_account)
          assert_equal 1, AccountReverification.count
          assert AccountReverification.exists?(account_id: @success_account.id)
          assert_equal 'initial', @success_account.account_reverification.status
        end

        it "should test the process of creating an account_reverification with 'initial' status for a successful delivery" do
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(SuccessMessage.new).once
          AccountReverification.stubs(:success_queue).returns(mock_queue)
          AccountReverification.expects(:find_account_by_email).returns(@success_account).once
          AccountReverification.expects(:create_account_reverification).with(@success_account).once
          AccountReverification.poll_success_queue
        end
      end


      describe 'hard bounce scenario' do
        it 'should delete an account that returns a hard permanent bounce' do
          account = create(:account_without_verifications, :hard_bounce)
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(HardBounceMessage.new).once
          AccountReverification.stubs(:bounce_queue).returns(mock_queue)
          AccountReverification.expects(:store_email_for_later_retry).never
          AccountReverification.poll_bounce_queue
          assert_not Account.exists?(email: account.email)
        end
      end

      describe 'transient bounce scenario' do
    
        it 'should store a transient email message for later reuse and not delete an account' do
          account = create(:account_without_verifications, :soft_bounce)
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
          AccountReverification.stubs(:bounce_queue).returns(mock_queue)
          AccountReverification.expects(:destroy_account).never
          AccountReverification.expects(:store_email_for_later_retry).with(account.email).once
          AccountReverification.poll_bounce_queue
          assert Account.exists?(email: account.email)
        end

        it 'should retry the correct verification notice' do
          account = create(:account_without_verifications, :soft_bounce)
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
          AccountReverification.stubs(:transient_bounce_queue).returns(mock_queue)
          AccountReverification.expects(:account_reverification_present?).with(account).returns(false)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.marked_for_spam_notice(account.email)).never
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(account.email)).once
          AccountReverification.poll_transient_bounce_queue
        end

        it 'should not resend a verification to a message in the transient bounce queue if the ses limit is reached' do
          account = create(:account_without_verifications, :soft_bounce)
          AccountReverification.expects(:ses_limit_reached?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.marked_for_spam_notice(account.email)).never
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(account.email)).never
          AccountReverification.poll_transient_bounce_queue
        end
      end
    end

    describe 'marked as spam phase' do

      describe 'accounts with initial notice' do
        it 'should grab accounts that only have an initial notice' do
          create_list(:account_with_an_initial_notification_and_no_verifications, 3)
          # The account below has no initial notice
          create_list(:account_without_verifications, 2)
          assert_equal 3, AccountReverification.accounts_with_initial_notice(5).count
        end
      end

      it "should send a 'marked for spam' notification to the correct accounts 13 days from initial notice" do
        correct_account = create(:account_with_an_initial_notification_and_no_verifications)
        correct_account_ar = correct_account.account_reverification
        account_without_initial_notice = create(:account_without_verifications)
        verified_account = create(:account)
        AccountReverification.stubs(:time_is_right?).returns(true)
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.marked_for_spam_notice(correct_account.email)).once
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.marked_for_spam_notice(account_without_initial_notice.email)).never
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.marked_for_spam_notice(verified_account.email)).never
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(correct_account.email)).never
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(verified_account.email)).never
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.marked_for_spam_notice(verified_account.email)).never
        AccountReverification.send_marked_for_spam_notification
      end

      it "should not send a 'marked for spam' notification to accounts if the time is incorrect" do
        correct_account = create(:account_with_an_initial_notification_and_no_verifications)
        correct_account_ar = correct_account.account_reverification
        account_without_initial_notice = create(:account_without_verifications)
        verified_account = create(:account)
        AccountReverification.stubs(:time_is_right?).returns(false)
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.marked_for_spam_notice(correct_account.email)).never
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.marked_for_spam_notice(account_without_initial_notice.email)).never
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.marked_for_spam_notice(verified_account.email)).never
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(correct_account.email)).never
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(verified_account.email)).never
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.marked_for_spam_notice(verified_account.email)).never
        AccountReverification.send_marked_for_spam_notification
      end

      it 'should not send an email if max quota has been met' do
        account = create(:account_with_an_initial_notification_and_no_verifications)
        create(:account_without_verifications)
        AccountReverification.expects(:ses_limit_reached?).returns(true)
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.marked_for_spam_notice(account.email)).never
        AccountReverification.send_marked_for_spam_notification
      end

      describe "process for a successful 'marked as spam' delivery" do
        it "should test the process of correctly updating an account's account_reverification status and updated_at attributes" do
          account = create(:account_with_an_initial_notification_and_no_verifications)
          updated_account_reverification = account.account_reverification.updated_at + 13.days
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(SuccessMessage.new).once
          AccountReverification.stubs(:success_queue).returns(mock_queue)
          Account.expects(:find_by_email).returns(account).once
          AccountReverification.expects(:update_account_reverification).with(account).returns(updated_account_reverification)
          AccountReverification.poll_success_queue
        end

        it 'should test the update_reverification method' do
          past = DateTime.now.utc - 13.days
          account = create(:account_with_an_initial_notification_and_no_verifications, created_at: past, updated_at: past)
          AccountReverification.update_account_reverification(account)
          assert_equal 'marked for spam', account.account_reverification.status
          assert_equal DateTime.now.in_time_zone.to_i, account.account_reverification.updated_at.to_i
          assert_not_equal past, account.account_reverification.updated_at
        end
      end

      describe "process for transient bounces with 'marked as spam' deliveries" do
        it "should resend the correct retry email for 'marked as spam' deliveries" do
          account = create(:account_with_an_initial_notification_and_no_verifications, email: 'ooto@simulator.amazonses.com')
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
          AccountReverification.stubs(:transient_bounce_queue).returns(mock_queue)
          AccountReverification.stubs(:account_reverification_present?).returns(true)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.marked_for_spam_notice(account.email)).once
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(account.email)).never
          AccountReverification.poll_transient_bounce_queue
        end

        it "should not resend 'marked as spam' deliveries when condition is false" do
         account = create(:account_with_an_initial_notification_and_no_verifications, email: 'ooto@simulator.amazonses.com')
          mock_queue = mock('AWS::SQS::Queue::MOCK')
          mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
          AccountReverification.stubs(:transient_bounce_queue).returns(mock_queue)
          AccountReverification.stubs(:account_reverification_present?).returns(false)
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.marked_for_spam_notice(account.email)).never
          AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(account.email)).once
          AccountReverification.poll_transient_bounce_queue
        end
      end
    end
  end
end
