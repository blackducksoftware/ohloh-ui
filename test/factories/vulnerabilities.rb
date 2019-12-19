# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerability do
    sequence :cve_id
    score { 1.0 }
    generated_on { 1.year.ago }
    published_on { 1.year.ago }
    severity { rand(0..2) }
  end
end
