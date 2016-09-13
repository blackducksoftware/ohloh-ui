FactoryGirl.define do
  factory :vulnerability do
    sequence :cve_id
    published_on { Faker::Date.backward(14) }
    generated_on { Faker::Date.backward(14) }
    score 1.0
    severity 'low'
  end
end
