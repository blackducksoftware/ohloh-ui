FactoryBot.define do
  factory :helpful do
    association :account
    association :review
    yes { true }
  end
end
