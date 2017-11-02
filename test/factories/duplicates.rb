FactoryBot.define do
  factory :duplicate do
    association :account
    association :good_project, factory: :project
    association :bad_project, factory: :project
    comment { Faker::Lorem.sentence }
  end
end
