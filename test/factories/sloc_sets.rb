# frozen_string_literal: true

FactoryBot.define do
  factory :sloc_set do
    association :code_set
  end
end
