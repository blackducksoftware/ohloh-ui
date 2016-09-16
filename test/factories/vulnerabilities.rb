FactoryGirl.define do
  factory :vulnerability do
    published_on { Faker::Date.backward(14) }
    generated_on { Faker::Date.backward(14) }
    score 1.0
    severity 'low'
    association :release
    sequence :cve_id
  end
end
