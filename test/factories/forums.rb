# frozen_string_literal: true

FactoryBot.define do
  factory :forum do
    name { Faker::Name.unique.name }
    description { Faker::Lorem.sentence }

    factory :forum_with_topics do
      transient do
        topics_count { 10 }
      end

      after(:create) do |forum, evaluator|
        create_list(:topic, evaluator.topics_count, forum: forum)
      end
    end
  end
end
