# frozen_string_literal: true

require_relative '../../test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  let(:account) { create(:account) }

  before do
    @account_subscription_service = Account::Subscription.new(account)
  end

  describe 'unsubscribe' do
    it 'should unsubscribe email notifications for kudos' do
      @account_subscription_service.unsubscribe(:kudo)
      _(account.email_kudos?).must_equal false
    end

    it 'should unsubscribe email notifications for posts' do
      @account_subscription_service.unsubscribe(:post)
      _(account.email_posts?).must_equal false
    end

    it 'should unsubscribe email notifications for all non-administrative emails' do
      @account_subscription_service.unsubscribe
      _(account.email_master?).must_equal false
    end
  end

  describe 'generate_unsubscription_key' do
    it 'should generate unsubscription key code' do
      _(@account_subscription_service.generate_unsubscription_key).must_be :present?
    end
  end
end
