FactoryGirl.define do
  factory :vita_language_fact do
    association :vita, factory: :best_vita
    association :language
    total_months 10
    total_commits 10
    total_activity_lines 10
  end
end
