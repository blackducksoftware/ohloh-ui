FactoryGirl.define do
  sequence :name_name do |n|
    "name-#{n}"
  end

  factory :name do
    name { generate(:name_name) }

    factory :name_with_fact do
      after(:create) do |name|
        NameFact.create!(name: name)
      end
    end
  end
end
