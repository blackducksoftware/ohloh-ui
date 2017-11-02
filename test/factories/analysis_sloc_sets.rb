FactoryBot.define do
  factory :analysis_sloc_set do
    association :analysis
    association :sloc_set
  end
end
