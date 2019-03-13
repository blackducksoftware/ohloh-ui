FactoryBot.define do
  factory :vita_language_fact do
    association :vita, factory: :best_vita
    association :most_commits_project, factory: :project
    association :recent_commit_project, factory: :project
    association :language
    total_months { 10 }
    total_commits { 10 }
    total_activity_lines { 10 }
  end
end
