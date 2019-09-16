# frozen_string_literal: true

FactoryBot.define do
  factory :stack do
    association :account
    title { Faker::Lorem.characters(20) }
    description { Faker::Lorem.characters(120) }
  end
end
