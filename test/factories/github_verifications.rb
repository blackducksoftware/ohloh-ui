FactoryBot.define do
  factory :github_verification do
    code { Faker::Internet.password }
    auth_id { Faker::Internet.password }
  end
end
