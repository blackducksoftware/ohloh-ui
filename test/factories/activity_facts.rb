FactoryGirl.define do
  factory :activity_fact do
    association :name
    association :language
    association :analysis
    code_added 10
    code_removed 5
    comments_added 4
    comments_removed 2
  end
end
