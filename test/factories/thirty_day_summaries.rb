FactoryGirl.define do
  factory :thirty_day_summary do
    association :analysis
    committer_count 2
    commit_count 3
    files_modified 4
    lines_added 5
    lines_removed 6
  end
end
