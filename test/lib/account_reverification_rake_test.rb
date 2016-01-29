require 'test_helper'

class AccountReverificationsTaskTest < ActiveSupport::TestCase

  describe 'send_first_reverification_notice' do
    before do
      # OhlohUi::Application.load_tasks
      # Rake::Task['reverification:send_first_reverification_email']
      # Rake::Task['reverification:send_first_reverification_email'].invoke
      create(:account_with_no_verifications, :success)
      create(:account_with_no_verifications, :complaint)
      create(:account_with_no_verifications, :hard_bounce)
      create(:account_with_no_verifications, :soft_bounce)
      create(:account)
    end

    after do
      Rake::Task.clear
    end

    def accounts_without_verifications
      Account.find_by_sql("SELECT accounts.email FROM accounts
                        LEFT OUTER JOIN verifications ON verifications.account_id = accounts.id
                        WHERE verifications.account_id is NULL ")
    end

    it 'should only send notifications to accounts that have not verified' do
      mock_class = mock(AccountReverification)
      assert_equal 4, accounts_without_verifications.count
      assert_not_equal Account.count, accounts_without_verifications.count
    end

    it 'an account should receive only the first reverification notice' do
      assert_match '/Please reverify your Open Hub account/', 
    end

    it 'should delete an account that returns a hard bounce' do
      # How can I test this with AWS and rails? Only AWS will return the object I need.
    end

    it "should send a soft bounce to the 'ses-transientbounces-queue'" do
    end

    it 'should not send an email if max quota has been met' do
    end

    it 'should generate an email response to info@openhub.net when a complaint is generated' do
    end

    it 'should increment reverification_attempt counter and reverification_notice once successful notice is sent' do
    end

    it 'should not increment reverification_attempt counter and reverification_notice if email is a transient bounce' do
    end

  end

  # describe 'retry_notification' do
  #   before do
  #     OhlohUi::Application.load_tasks
  #     Rake::Task['reverification:retry_notification']
  #   end

  #   after do
  #     Rake::Task.clear
  #   end

  #   it "should send notifications to accounts that are only in the 'ses-transientbounces-queue'" do
      
  #   end

  #   it 'should delete accounts that returns a hard bounce' do
      
  #   end

  #   it "should send a soft bounce to the 'ses-transientbounces-queue'" do
  #   end

  #   it 'should send the correct notification based on stage of the verification process' do
  #   end

  #   it 'should not send an email if max quota has been met' do
  #   end

  #   it 'should increment reverification_attempt counter and reverification_notice once successful notice is sent' do
  #   end

  #   it 'should not increment reverification_attempt counter and reverification_notice if email is a transient bounce' do
  #   end

  # end
end