# frozen_string_literal: true

FactoryBot.define do
  factory :scan_analytic do
    association :code_set
    association :analysis
    data_type { 'Analytics' }
  end
end
