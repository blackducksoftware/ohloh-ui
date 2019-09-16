# frozen_string_literal: true

FactoryBot.define do
  factory :org_thirty_day_activity do
    name        { Faker::Company.name + rand(999_999).to_s }
    vanity_url  { Faker::Lorem.word + rand(999_999).to_s }
    org_type { 1 }
    project_count { 2 }
    affiliate_count { 20 }
    thirty_day_commit_count { 200 }
    association :organization
  end
end
