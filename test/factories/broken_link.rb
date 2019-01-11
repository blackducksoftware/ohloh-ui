FactoryBot.define do
  factory :broken_link do
    association :link
    error { Faker::Lorem.word }
  end
end
