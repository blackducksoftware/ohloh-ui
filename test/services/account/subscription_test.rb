require 'test_helper'

class Account::SubscrptionTest < ActiveSupport::TestCase
  let(:account) { create(:account) }

  describe 'unsubscribe' do
    before do
      @account_subscription_service = Account::Subscription.new(account)
    end

    it 'should unsubscribe email notifications for kudos' do
      @account_subscription_service.unsubscribe(:kudo)
      account.email_kudos?.must_equal false
    end

    it 'should unsubscribe email notifications for posts' do
      @account_subscription_service.unsubscribe(:post)
      account.email_posts?.must_equal false
    end

    it 'should unsubscribe email notifications for all non-administrative emails' do
      @account_subscription_service.unsubscribe
      account.email_master?.must_equal false
    end
  end
end
