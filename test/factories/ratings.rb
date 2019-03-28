FactoryBot.define do
  factory :rating do
    association :account
    association :project
    score { 3 }
  end
end
