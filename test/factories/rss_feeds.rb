FactoryBot.define do
  factory :rss_feed do
    url { Faker::Internet.url }
  end
end
