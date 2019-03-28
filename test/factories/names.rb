FactoryBot.define do
  factory :name do
    name { Faker::Name.first_name + rand(999_999).to_s }

    factory :name_with_fact do
      after(:build) do |name|
        NameFact.create!(name: name, analysis_id: create(:project).best_analysis_id)
      end
    end
  end
end
