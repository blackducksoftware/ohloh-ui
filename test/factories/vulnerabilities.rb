FactoryGirl.define do
  factory :vulnerability do
    cve_id { Faker::Lorem.word }
  end
end
