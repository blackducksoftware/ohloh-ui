# frozen_string_literal: true

FactoryBot.define do
  factory :project_experience do
    association :position
    association :project
  end
end
