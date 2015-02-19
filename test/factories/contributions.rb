FactoryGirl.define do
  factory :contribution do
    association :person
    association :project
    association :position
    association :contributor_fact
  end
end
