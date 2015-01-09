FactoryGirl.define do
  factory :person do
    name_id 1
    project_id 2
    effective_name nil
    association :name_fact
  end
end
