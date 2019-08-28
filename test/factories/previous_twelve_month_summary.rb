# frozen_string_literal: true

FactoryBot.define do
  factory :previous_twelve_month_summary do
    affiliated_committers_count { 4 }
    affiliated_commits_count { 4 }
    outside_committers_count { 4 }
    outside_commits_count { 4 }
  end
end
