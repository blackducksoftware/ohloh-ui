FactoryGirl.define do
  factory :release do
    association :project_security_set
    release_id { Faker::Lorem.word }
  end
end
