FactoryGirl.define do
  factory :name do
    name { Faker::Name.first_name }

    factory :name_with_fact do
      after(:create) do |name|
        NameFact.create!(name: name)
      end
    end
  end
end
