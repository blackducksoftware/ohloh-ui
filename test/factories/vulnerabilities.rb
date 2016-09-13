FactoryGirl.define do
  factory :vulnerability do
    cve_id { Faker::Lorem.characters(20) }
    published_on { Faker::Date.backward(14) }
    generated_on { Faker::Date.backward(14) }
    score 1.0
    severity 'low'
    association :release
  end
end
