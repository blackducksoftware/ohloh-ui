FactoryGirl.define do
  factory :repository do
    url { Faker::Internet.url }
    module_name { Faker::Lorem.characters(16) }
    branch_name { Faker::Lorem.characters(16) }
    type 'GitRepository'
  end
end
