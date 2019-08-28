# frozen_string_literal: true

FactoryBot.define do
  factory :manage do
    association :account
    association :target, factory: :project
  end
end
