FactoryGirl.define do
  factory :project_badge do
    identifier 'MyString'
    association :project
    association :repository
  end
end

FactoryGirl.define do
  factory(:travis_badge) do
    identifier "#{Faker::Lorem.word}/#{Faker::Lorem.word}.git?branch=#{Faker::Lorem.word}"
  end
end

FactoryGirl.define do
  factory(:cii_badge) do
    sequence :identifier do |n|
      n + 1
    end
  end
end
