FactoryGirl.define do
  factory :analysis do
    association :project
    association :main_language, factory: :language
  end
end
