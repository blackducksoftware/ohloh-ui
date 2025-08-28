# frozen_string_literal: true

FactoryBot.define do
  factory :invite do
    association :project
    activation_code { Faker::Lorem.characters(number: 10) }
    association :invitor, factory: :account
    invitee_email { Faker::Internet.email }
    association :name, factory: :name_with_fact
    after(:build) do |obj|
      name_fact = NameFact.last
      Person.rebuild_by_project_id(name_fact.analysis.project_id)
      obj.contribution = Contribution.find_by(name_fact_id: name_fact.id)
    end
  end
end
