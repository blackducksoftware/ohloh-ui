FactoryGirl.define do
  factory :release do
    kb_release_id { Faker::Lorem.word }
    association :project_security_set
  end
end
