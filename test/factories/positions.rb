FactoryGirl.define do
  factory :position do
    association :project
    association :account
    association :name
  end
end
