# frozen_string_literal: true

FactoryBot.define do
  factory :all_time_summary do
    association :analysis
    affiliated_committers_count { 2_999 }
    affiliated_commits_count { 2_111 }
    outside_committers_count { 2_222 }
    outside_commits_count { 2_000 }
  end

  factory :all_time_summary_summary_with_name_ids, parent: :all_time_summary do
    after(:create) do |all_time_summary|
      name_fact = create(:name_fact, analysis: all_time_summary.analysis)
      all_time_summary.update(recent_contributors: ['name_ids', name_fact.name.id])
    end
  end
end
