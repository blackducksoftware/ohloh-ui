FactoryGirl.define do
  factory :reverification do
    association :account
    verified false
    initial_email_sent_at Time.now.utc
    reminder_sent_at nil
    notification_counter 0
  end
end
