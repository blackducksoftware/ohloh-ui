FactoryGirl.define do
  factory :language_fact do
    association :language
    month { Time.now }
  end
end
