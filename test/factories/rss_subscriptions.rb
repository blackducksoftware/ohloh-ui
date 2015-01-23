FactoryGirl.define do
  factory :rss_subscription do
    association :project
    association :rss_feed_id
  end
end
