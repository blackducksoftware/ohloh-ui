# frozen_string_literal: true

FactoryBot.define do
  factory :release do
    kb_release_id { Faker::Lorem.word }
    sequence :version do |n|
      "#{n}.#{n}.#{n}"
    end
    released_on { Faker::Date.between(from: 20.years.ago, to: Time.zone.today) }
    association :project_security_set
  end

  factory :major_release_one, parent: :release do
    sequence :version do |n|
      "1.#{n}.#{n}"
    end
    released_on { Faker::Date.between(from: 20.years.ago, to: 15.years.ago) }
  end

  factory :major_release_two, parent: :release do
    sequence :version do |n|
      "2.#{n}.#{n}"
    end
    released_on { Faker::Date.between(from: 14.years.ago, to: 10.years.ago) }
  end

  factory :major_release_three, parent: :release do
    sequence :version do |n|
      "3.#{n}.#{n}"
    end
    released_on { Faker::Date.between(from: 9.years.ago, to: 5.years.ago) }
  end

  factory :major_release_four, parent: :release do
    sequence :version do |n|
      "4.#{n}.#{n}"
    end
    association :project_security_set
    released_on { 6.months.ago }
    after(:create) do |release|
      pss_id = release.project_security_set_id
      project = release.project_security_set.project
      project.update_column('best_project_security_set_id', pss_id)
    end
  end
end
