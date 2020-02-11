# frozen_string_literal: true

FactoryBot.define do
  factory :account_analysis_language_fact do
    association :account_analysis, factory: :best_account_analysis
    association :most_commits_project, factory: :project
    association :recent_commit_project, factory: :project
    association :language
    total_months { 10 }
    total_commits { 10 }
    total_activity_lines { 10 }
  end
end
