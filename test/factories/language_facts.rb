# frozen_string_literal: true

FactoryBot.define do
  factory :language_fact do
    association :language
    month { Time.current }
  end
end
