# frozen_string_literal: true

require 'test_helper'

class RssSubscriptionTest < ActiveSupport::TestCase
  it 'should validate RSS feed and permission' do
    rss_subscription = build(:rss_subscription, rss_feed_id: nil)
    _(rss_subscription).wont_be :valid?
    message = 'You are not authorized to edit this RssSubscription'
    _(rss_subscription.errors.messages[:permission].first).must_equal message
    _(rss_subscription.errors.messages[:rss_feed_id].first).must_equal 'can\'t be blank'
  end

  it 'should create RSS Subscription for a valid' do
    rss_subscription = create(:rss_subscription)
    _(rss_subscription).must_be :valid?
    _(rss_subscription.explain_yourself).must_include 'Subscribed to RSS feed'
  end
end
