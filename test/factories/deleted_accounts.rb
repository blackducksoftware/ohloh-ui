# frozen_string_literal: true

FactoryBot.define do
  factory :deleted_account do
    email { Faker::Internet.email }
    login { Faker::Internet.user_name }
    reasons { [Random.rand(1..5)] }

    factory :other_reasons do
      reasons { [6] }
      reason_other { Faker::Lorem.sentence }
    end
  end
end
