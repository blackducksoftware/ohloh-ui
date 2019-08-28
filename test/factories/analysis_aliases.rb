# frozen_string_literal: true

FactoryBot.define do
  factory :analysis_alias do
    association :analysis
    association :commit_name, factory: :name
    association :preferred_name, factory: :name
  end
end
