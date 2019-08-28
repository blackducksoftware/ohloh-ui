# frozen_string_literal: true

FactoryBot.define do
  factory :project_badge do
    identifier { 'MyString' }
    association :enlistment
  end
end

FactoryBot.define do
  factory(:travis_badge) do
    identifier { "#{Faker::Lorem.word}/#{Faker::Lorem.word}.git?branch=#{Faker::Lorem.word}" }
  end
end

FactoryBot.define do
  factory(:cii_badge) do
    sequence :identifier do |n|
      n + 1
    end
  end
end
