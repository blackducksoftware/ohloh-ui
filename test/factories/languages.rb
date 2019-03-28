FactoryBot.define do
  factory :language do
    category { 0 }
    name { Faker::Lorem.characters(10) }
    nice_name { Faker::Lorem.characters(10) }
    sequence :code do |n|
      n + 1
    end
    sequence :commits do |n|
      n + 1
    end
    sequence :blanks do |n|
      n + 1
    end
  end
end
