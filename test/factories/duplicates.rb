# frozen_string_literal: true

FactoryBot.define do
  factory :duplicate do
    association :account
    association :good_project, factory: :project, strategy: :create
    association :bad_project, factory: :project, strategy: :create
    comment { Faker::Lorem.sentence }
  end
end
