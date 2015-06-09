FactoryGirl.define do
  factory :topic do
    association :forum
    association :account

    sequence :title do |n|
      "Topic number#{n}"
    end
    sequence :sticky do |n|
      "#{n}"
    end
    sequence :replied_at do |n|
      Time.current + n
    end

    factory :topic_with_posts, parent: :topic do
      transient do
        posts_count 3
      end

      after(:create) do |topic, evaluator|
        create_list(:post, evaluator.posts_count, topic: topic)
      end
    end
  end
end
