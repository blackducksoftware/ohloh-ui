FactoryGirl.define do
  factory :contribution do
    association :project
    association :person
    # association :name
    # association :position

    after(:create) do |instance|
      instance.update_attributes(person: create(:person))
      instance.update_attributes(project: instance.project)
    end
  end
end
