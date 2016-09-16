FactoryGirl.define do
  factory :vulnerability do
<<<<<<< HEAD
    cve_id { Faker::Lorem.characters(20) }
    published_on { Faker::Date.backward(14) }
    generated_on { Faker::Date.backward(14) }
    score 1.0
    severity 'low'
    association :release
=======
    sequence :cve_id
>>>>>>> 2e91ced42e3738d0661d623143052a176891afd1
  end
end
