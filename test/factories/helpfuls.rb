# frozen_string_literal: true

FactoryBot.define do
  factory :helpful do
    association :account
    association :review
    yes { true }
  end
end
