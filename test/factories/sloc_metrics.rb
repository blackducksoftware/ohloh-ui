# frozen_string_literal: true

FactoryBot.define do
  factory :sloc_metric do
    association :sloc_set
    association :diff
    association :language
    code_added { Faker::Number.number(digits: 2) }
    code_removed { Faker::Number.number(digits: 2) }
    comments_added { Faker::Number.number(digits: 2) }
    comments_removed { Faker::Number.number(digits: 2) }
    blanks_added { Faker::Number.number(digits: 2) }
    blanks_removed { Faker::Number.number(digits: 2) }
  end
end
