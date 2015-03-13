FactoryGirl.define do
  factory :commit do
    association :code_set
    association :name
    time { Time.now - 3.days }
  end
end
