FactoryGirl.define do
  factory :pss_release_vulnerability do
    association :release
    association :vulnerability
    association :project_security_set
  end
end
