FactoryGirl.define do
  factory :release do
    association :project_security_set
    kb_release_id
  end
  sequence(:kb_release_id) { |n| "#{Faker::Lorem.word}-#{n}" }
end
