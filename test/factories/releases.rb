FactoryGirl.define do
  factory :release do
    kb_release_id { Faker::Lorem.word }
    sequence :version do |n|
      "#{n}.#{n}.#{n}"
    end
    released_on { Faker::Date.between(20.years.ago, Time.zone.today) }
    association :project_security_set
  end

  factory :major_release_one, parent: :release do
    sequence :version do |n|
      "1.#{n}.#{n}"
    end
  end

  factory :major_release_two, parent: :release do
    sequence :version do |n|
      "2.#{n}.#{n}"
    end
  end

  factory :major_release_three, parent: :release do
    sequence :version do |n|
      "3.#{n}.#{n}"
    end
  end
end
