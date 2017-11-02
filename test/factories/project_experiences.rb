FactoryBot.define do
  factory :project_experience do
    association :position
    association :project
  end
end
