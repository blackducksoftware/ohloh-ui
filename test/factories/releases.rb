FactoryGirl.define do
  factory :release do
    association :project_security_set
    release_id
  end
  sequence(:release_id) { |n| "#{Faker::Lorem.word}-#{n}" }
end
