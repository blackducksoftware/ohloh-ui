FactoryGirl.define do
  factory :name do
    name { Faker::Name.first_name + rand(999_999).to_s }

    factory :name_with_fact do
      after(:create) do |name|
        NameFact.create!(name: name)
      end
    end
  end
end
