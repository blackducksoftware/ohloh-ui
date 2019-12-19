# frozen_string_literal: true

FactoryBot.define do
  factory :rss_article do
    title { Faker::Lorem.paragraph }
    description { Faker::Lorem.paragraph }
    guid { Faker::Internet.url }
    author { Faker::Name.name }
    time { 5.days.ago }
    association :rss_feed
  end
end
