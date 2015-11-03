# Note: This factory cannot be created with FactoryGirl
# It can be stubbed with FactoryGirl's build_stubbed method
# Example: contribution = build_stubbed(:contribution)
FactoryGirl.define do
  factory :contribution do
    association :person
    association :project
    association :position
    association :contributor_fact

    after(:create) do |instance|
      instance.update_attributes(person: create(:person))
      instance.update_attributes(project: instance.project)
    end
  end
end
