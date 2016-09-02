FactoryGirl.define do
  sequence :version do |n|
    "login-#{n}"
  end

  factory :release do
    sequence :version do |n|
      "#{n}.#{n}.#{n}"
    end

    release_id { SecureRandom.uuid }
    released_on { Faker::Date.backward(14) }
    association :project_security_set
  end
end
