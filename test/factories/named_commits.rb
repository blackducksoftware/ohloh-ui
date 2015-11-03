# Note: This factory cannot be created with FactoryGirl
# It can be stubbed with FactoryGirl's build_stubbed method
# Example: named_commit = build_stubbed(:named_commit)
FactoryGirl.define do
  factory :named_commit do
    association :commit
    association :analysis
    association :project
    association :account
    association :position
    association :contribution
    association :person
  end
end
