FactoryGirl.define do
  factory :vita_language_fact do
    association :vita, factory: :best_vita
    association :language
  end
end
