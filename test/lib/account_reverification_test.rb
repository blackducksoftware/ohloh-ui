require 'test_helper'

class AccountReverificationTest < ActiveSupport::TestCase

  class MsgBody
    def body_message_as_h
      byebug
      hard_bounce_json
    end
  end

  class HardBounceMessage
    def as_sns_message
      MsgBody.new
    end
  end

  describe 'AccountReverification' do
   
    # it 'should only select accounts that have no verifications' do
    #   create(:account_with_no_verifications, :success)
    #   create(:account_with_no_verifications, :complaint)
    #   create(:account_with_no_verifications, :hard_bounce)
    #   create(:account_with_no_verifications, :soft_bounce)
    #   create(:account)
    #   assert_equal 4, AccountReverification.accounts_without_verifications(5).count
    #   assert_not_equal Account.count, AccountReverification.accounts_without_verifications(5).count
    # end

    # it 'an account should receive only the first reverification notice' do
    #   account = create(:account_with_no_verifications, :success)
    #   AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(account)).once
    #   AccountReverification.expects(:destroy_account).with(account).never
    #   AccountReverification.expects(:store_email_for_later_retry).with(account).never
    #   AccountReverification.run
    # end

    # it 'should not send an email if max quota has been met' do
    #   account = create(:account_with_no_verifications, :success)
    #   AccountReverification.expects(:ses_limit_reached?).returns(true)
    #   AWS::SimpleEmailService.any_instance.expects(:send_mail).never
    #   AccountReverification.run
    # end

    it 'should delete an account that returns a hard bounce' do
      # Create an account
      account = create(:account_with_no_verifications, :hard_bounce)
      
      # mock the SQS queue
      mock_queue = mock('AWS::SQS::Queue::MOCK')

      # have the mocked SQS queue expect the :poll message and return a valid bounce message for the above account
      mock_queue.stubs(:poll).yields(HardBounceMessage.new)

      # Stub AccountReverification.bounced_queue to return the mock
      AccountReverification.stubs(:bounce_queue).returns(mock_queue)

      AccountReverification.expects(:destroy_account).with(account.email)
      # AccountReverification.expects(:store_email_for_later_retry).never

      # Run the AccountReverification
      AccountReverification.run

      # Verify the created account is no longer in the Accounts table
      assert_not Account.exists?(email: account.email)
    end

    # it "should send a soft bounce to the 'ses-transientbounces-queue'" do
    # end

    # it 'should generate an email response to info@openhub.net when a complaint is generated' do
    # end

    # it 'should increment reverification_attempt counter and reverification_notice once successful notice is sent' do
    # end

    # it 'should not increment reverification_attempt counter and reverification_notice if email is a transient bounce' do
    # end
  end
end
