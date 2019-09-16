# frozen_string_literal: true

FactoryBot.define do
  factory :kudo do
    association :sender, factory: :account
    association :account
    association :project
    message { Faker::Lorem.sentence(2) }
  end

  factory :kudo_with_name, parent: :kudo do
    association :name, factory: :name_with_fact
    after(:create) do |kudo|
      Person.create!(name_id: kudo.name_id, project_id: kudo.project_id, name_fact_id: kudo.name.name_facts.first.id)
    end
  end
end
