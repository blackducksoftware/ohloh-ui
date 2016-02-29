FactoryGirl.define do
  factory :reverification_tracker do
    association :account
    message_id 0
    feedback ''
    phase 0
    status 0
    created_at DateTime.now.utc
    updated_at DateTime.now.utc
  end
end
