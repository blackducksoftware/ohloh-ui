FactoryGirl.define do
  factory :reverification do
    association :account
    twitter_reverified false
    twitter_reverification_sent_at Time.now.utc
    reminder_sent_at nil
    notification_counter 0
  end
end
