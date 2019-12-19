# frozen_string_literal: true

FactoryBot.define do
  factory :contribution do
    association :person
    association :project
    association :position
    association :contributor_fact

    after(:create) do |instance|
      instance.update(person: create(:person))
      instance.update(project: instance.project)
    end
  end
end
