# frozen_string_literal: true

FactoryBot.define do
  factory :language_experience do
    association :position
    association :language
  end
end
