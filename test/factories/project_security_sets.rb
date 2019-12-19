# frozen_string_literal: true

FactoryBot.define do
  factory :project_security_set do
    association :project
    uuid { Faker::Lorem.word }

    after(:create) do |pss|
      pss.project.editor_account = create(:admin)
      pss.project.update best_project_security_set_id: pss.id
    end
  end
end
