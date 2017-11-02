FactoryBot.define do
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
