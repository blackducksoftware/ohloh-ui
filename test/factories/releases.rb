FactoryGirl.define do
  factory :release do
    sequence :version do |n|
      "#{n}.#{n}.#{n}"
    end
    kb_release_id { Faker::Lorem.characters(10)}
    released_on { Faker::Date.between(15.years.ago, Time.zone.today) }
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
