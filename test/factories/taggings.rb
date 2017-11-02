FactoryBot.define do
  factory :tagging do
    association :tag
    association :taggable, factory: :project
  end
end
