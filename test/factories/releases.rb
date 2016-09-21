FactoryGirl.define do
  factory :release do
    association :project_security_set
    sequence :version do |n|
      "#{n}.#{n}.#{n}"
    end
    kb_release_id { Faker::Lorem.word }
    released_on { Faker::Date.between(6.years.ago, Time.zone.today) }
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
