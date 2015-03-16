FactoryGirl.define do
  factory :post do
    association :account, factory: :account
    association :topic
    body { Faker::Lorem.sentence }
    sequence :created_at do |n|
      Time.now + n
    end
  end
end
