FactoryGirl.define do
  factory :kudo do
    sender_id 1
    account_id 1
    project_id 1
    message Faker::Lorem.sentence
  end
end
