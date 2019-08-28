# frozen_string_literal: true

FactoryBot.define do
  factory :twelve_month_summary do
    association :analysis
    affiliated_committers_count { 2 }
    affiliated_commits_count { 2 }
    outside_committers_count { 2 }
    outside_commits_count { 2 }
    recent_contributors { [] }
  end
end
