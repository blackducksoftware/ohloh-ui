FactoryGirl.define do
  factory :project_security_set do
    association :project
    uuid { Faker::Lorem.word }
  end
end
