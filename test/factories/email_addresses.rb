FactoryBot.define do
  factory :email_address do
    address { Faker::Internet.email }
  end
end
