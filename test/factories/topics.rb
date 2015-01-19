FactoryGirl.define do
  factory :topic do
    association :account
    title { Faker::Name.title }
    closed false
  end
end
