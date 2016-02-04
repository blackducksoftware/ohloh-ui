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
    describe 'process method' do
      it 'should only select accounts that have no verifications' do
        create(:account_with_no_verifications, :success)
        create(:account_with_no_verifications, :complaint)
        create(:account_with_no_verifications, :hard_bounce)
        create(:account_with_no_verifications, :soft_bounce)
        create(:account)
        assert_equal 4, AccountReverification.accounts_without_verifications(5).count
        assert_not_equal Account.count, AccountReverification.accounts_without_verifications(5).count
      end

      it 'should only send notifications to accounts that do not have verifications only' do
        account_w_verification = create(:account)
        create_list(:account_with_no_verifications, 4)
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(account_w_verification.email)).never
        AWS::SimpleEmailService.any_instance.expects(:send_email).times(4)
        AccountReverification.send_first_notification
      end

      it 'an account should receive only the first reverification notice' do
        account = create(:account_with_no_verifications, :success)
        AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(account.email)).once
        AccountReverification.expects(:destroy_account).with(account.email).never
        AccountReverification.expects(:store_email_for_later_retry).with(account).never
        AccountReverification.send_first_notification
      end

      it 'should not send an email if max quota has been met' do
        account = create(:account_with_no_verifications, :success)
        AccountReverification.expects(:ses_limit_reached?).returns(true)
        AWS::SimpleEmailService.any_instance.expects(:send_email).never
        AccountReverification.send_first_notification
      end
    end

    describe 'success scenario' do
      before do
        @success_account = create(:account_with_no_verifications, :success)
      end

      it 'should create an associated account reverification with status set to initial' do
        AccountReverification.create_reverification(@success_account)
        assert_equal 1, AccountReverification.count
        assert AccountReverification.exists?(account_id: @success_account.id)
        assert_equal 'initial', @success_account.account_reverification.status
      end

      it "should create an account_reverification with 'initial' status for a successful delivery" do
        mock_queue = mock('AWS::SQS::Queue::MOCK')
        mock_queue.stubs(:poll).yields(SuccessMessage.new).once
        AccountReverification.stubs(:success_queue).returns(mock_queue)
        Account.expects(:find_by_email).returns(@success_account).once
        AccountReverification.expects(:create_reverification).with(@success_account).once
        AccountReverification.poll_success_queue
      end
    end

    describe 'hard bounce scenario' do
      it 'should delete an account that returns a hard permanent bounce' do
        account = create(:account_with_no_verifications, :hard_bounce)
        mock_queue = mock('AWS::SQS::Queue::MOCK')
        mock_queue.stubs(:poll).yields(HardBounceMessage.new).once
        AccountReverification.stubs(:bounce_queue).returns(mock_queue)
        AccountReverification.expects(:store_email_for_later_retry).never
        AccountReverification.poll_bounce_queue
        assert_not Account.exists?(email: account.email)
      end
    end

    describe 'soft/transient bounce scenario' do
      before do
        @mock_queue = mock('AWS::SQS::Queue::MOCK')
        @mock_queue.stubs(:poll).yields(TransientBounceMessage.new).once
      end

      it 'should store a transient email message for later reuse and not delete an account' do
        account = create(:account_with_no_verifications, :soft_bounce)
        AccountReverification.stubs(:bounce_queue).returns(@mock_queue)
        AccountReverification.expects(:destroy_account).never
        AccountReverification.expects(:store_email_for_later_retry).once
        AccountReverification.poll_bounce_queue
        assert Account.exists?(email: account.email)
      end

      it 'should resend a verification if a message is found in the transient bounce queue' do
        AccountReverification.stubs(:transient_bounce_queue).returns(@mock_queue)
        AWS::SimpleEmailService.any_instance.expects(:send_email).once
        AccountReverification.poll_transient_bounce_queue
      end

      it 'should not resend a verification to a message in the transient bounce queue if the ses limit is reached' do
        AccountReverification.stubs(:transient_bounce_queue).returns(@mock_queue)
        AccountReverification.expects(:ses_limit_reached?).returns(true)
        AWS::SimpleEmailService.any_instance.expects(:send_email).never
        AccountReverification.poll_transient_bounce_queue
      end
    end
  end
end
