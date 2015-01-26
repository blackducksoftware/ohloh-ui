FactoryGirl.define do
  factory :language do
    category 0
    name { Faker::Lorem.characters(10) }
    nice_name { Faker::Lorem.characters(10) }
  end
end
