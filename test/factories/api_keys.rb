# frozen_string_literal: true

FactoryBot.define do
  factory :api_key do
    association :account
    association :oauth_application
    description { 'An API Key for account #1' }
    name { Faker::Lorem.characters(5) }
    key { Faker::Internet.slug }
    terms { '1' }
  end
end
