FactoryGirl.define do
  sequence :name_name do |n|
    "name-#{n}"
  end

  factory :name do
    name { generate(:name_name) }
  end
end
