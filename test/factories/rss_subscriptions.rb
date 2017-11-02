FactoryBot.define do
  factory :rss_subscription do
    association :project
    association :rss_feed
    before(:create) { |instance| instance.editor_account = create(:admin) }
  end
end
