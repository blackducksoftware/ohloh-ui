# frozen_string_literal: true

FactoryBot.define do
  factory :topic do
    association :forum
    association :account

    sequence :title do |n|
      "Topic number#{n}"
    end
    sequence :sticky
    sequence :replied_at do |n|
      Time.current + n
    end

    trait(:closed) { closed { true } }
    trait :with_posts do
      transient do
        posts_count { 3 }
      end

      after(:create) do |topic, evaluator|
        create_list(:post, evaluator.posts_count, topic: topic)
      end
    end
  end
end
