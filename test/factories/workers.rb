# frozen_string_literal: true

FactoryBot.define do
  factory :worker do
    hostname { Faker::Name.name }
    allow_deny { 'allow' }
    load_average { rand(10) }
    enable_profiling { false }
    blocked_types { nil }
  end
end
