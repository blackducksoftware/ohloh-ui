# frozen_string_literal: true

FactoryBot.define do
  factory :oauth_application, class: Doorkeeper::Application do
    name { Faker::Company.name }
    redirect_uri { Faker::Internet.url }
  end
end
