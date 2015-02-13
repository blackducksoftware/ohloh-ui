FactoryGirl.define do
  factory :vita do
    association :account
  end

  factory :best_vita, parent: :vita do
    association :vita_fact
  end
end
