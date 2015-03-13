FactoryGirl.define do
  factory :activity_fact do
    association :name
    association :language
    association :analysis
    month  { Date.today }
    code_added 100
    code_removed 100
    comments_added 100
    comments_removed 100
    blanks_added 100
    blanks_removed 100
    name_id 100
    commits 100
  end
end
