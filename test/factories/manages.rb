FactoryBot.define do
  factory :manage do
    association :account
    association :target, factory: :project
  end
end
