FactoryGirl.define do
  factory :vulnerability do
    association :release
    cve_id { Faker::Lorem.word }
  end
end
