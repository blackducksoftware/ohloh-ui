# frozen_string_literal: true

FactoryBot.define do
  factory :load_average do
    current { 2.25 }
    max { 10.00 }
  end
end
