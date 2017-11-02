FactoryBot.define do
  factory :forum do
    name { Faker::Name.title + rand(999_999).to_s }
    description { Faker::Lorem.sentence }

    factory :forum_with_topics do
      transient do
        topics_count 10
      end

      after(:create) do |forum, evaluator|
        create_list(:topic, evaluator.topics_count, forum: forum)
      end
    end
  end
end
