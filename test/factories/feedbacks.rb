FactoryBot.define do
  factory :feedback do
    association :project
    more_info { 1 }
    rating { 5 }
  end
end
