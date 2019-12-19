# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    association :account
    association :topic
    body { Faker::Lorem.sentence }
    sequence :created_at do |n|
      Time.current + n
    end
  end
end
