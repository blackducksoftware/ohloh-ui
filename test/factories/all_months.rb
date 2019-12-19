# frozen_string_literal: true

FactoryBot.define do
  factory :all_month do
    month { Date.current }
  end
end
