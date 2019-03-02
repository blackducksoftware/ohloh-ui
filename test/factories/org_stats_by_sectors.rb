FactoryBot.define do
  factory :org_stats_by_sector do
    org_type { 1 }
    organization_count { 10 }
    commits_count { 1000 }
    affiliate_count { 20 }
    average_commits { 50 }
  end
end
