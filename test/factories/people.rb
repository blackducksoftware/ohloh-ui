FactoryBot.define do
  factory :person do
    association :name
    association :project
    effective_name { nil }
    association :name_fact
  end
end
