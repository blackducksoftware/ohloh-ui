FactoryGirl.define do
  factory :vulnerability do
    trait :low do
      severity 'low'
    end

    trait :medium do
      severity 'medium'
    end

    trait :high do
      severity 'high'
    end

    cve_id { Faker::Lorem.characters(20) }
    published_on { Faker::Date.backward(14) }
    generated_on { Faker::Date.backward(14) }
    score 1.0

    factory :high_vuln, traits: :high
    factory :medium_vuln, traits: :medium
    factory :low_vuln, traits: :low
    association :release
  end
end
