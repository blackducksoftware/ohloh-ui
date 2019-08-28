# frozen_string_literal: true

FactoryBot.define do
  factory :diff do
    association :commit
    association :fyle
  end
end
