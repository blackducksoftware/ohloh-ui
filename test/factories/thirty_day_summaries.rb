FactoryBot.define do
  factory :thirty_day_summary do
    association :analysis
    files_modified { 4 }
    lines_added { 5 }
    lines_removed { 6 }
  end
end
