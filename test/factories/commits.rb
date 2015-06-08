FactoryGirl.define do
  factory :commit do
    association :code_set
    association :name
    time { Time.now.at_beginning_of_month }
  end
end
