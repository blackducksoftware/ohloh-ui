require 'test_helper'

class AccountReverificationTest < ActiveSupport::TestCase

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
    # #   # Create an account that has already had the first notification sent
    # #   # mock the SQS queue
    # #   # have the mocked SQS queue expect the :poll message and return a valid bounce message for the above account
    # #   # Stub AccountReverification.bounced_queue to return the mock
    # #   # Run the AccountReverification
    # #   # Verify the created account is no longer in the Accounts table

      account = create(:account_with_no_verifications, :hard_bounce)
      email_address = hard_bounce_json['bounce']['bouncedRecipients'][0]['emailAddress']
      # binding.pry
      # AWS::SimpleEmailService.any_instance.expects(:send_email).with(AccountReverification.first_reverification_notice(account)).once
      # AWS::SQS::Queue.any_instance.expects(:poll).with({initial_time: false, idle_timeout: 5}) { |value| AccountReverification.process_bounce(value) }.once
      AccountReverification.expects(:process_bounce).with(email_address).once
      AccountReverification.expects(:destroy_account).with(email_address).once
      AccountReverification.expects(:store_email_for_later_retry).with(email_address).never
      AccountReverification.run
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