# frozen_string_literal: true

FactoryBot.define do
  factory :fyle do
    name { Faker::Name.name + rand(999_999).to_s }
    association :code_set
  end
end
