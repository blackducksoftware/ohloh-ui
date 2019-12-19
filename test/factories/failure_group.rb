# frozen_string_literal: true

FactoryBot.define do
  factory :failure_group do
    name { Faker::Name.name }
    pattern { '%%' }
  end
end
