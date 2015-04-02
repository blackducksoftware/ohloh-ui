FactoryGirl.define do
  factory :activity_fact do
    association :name
    association :language
    analysis
    sequence :month do |n|
      Time.utc(Time.now.utc.year, "#{n}", 1)
    end
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
