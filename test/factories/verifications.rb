FactoryGirl.define do
  factory :verification do
    type 'Verification'
    created_at { Time.now.utc }
    auth_id { Faker::Internet.password }
    updated_at nil
  end
end
