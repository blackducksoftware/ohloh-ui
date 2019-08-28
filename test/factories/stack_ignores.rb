# frozen_string_literal: true

FactoryBot.define do
  factory :stack_ignore do
    association :stack
    association :project
  end
end
