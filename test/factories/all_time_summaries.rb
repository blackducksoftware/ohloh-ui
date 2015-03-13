FactoryGirl.define do
  factory :all_time_summary do
    association :analysis
    affiliated_committers_count 2_999
    affiliated_commits_count 2_111
    outside_committers_count 2_222
    outside_commits_count 2_000
  end
end
