FactoryBot.define do
  factory :project do
    name        { Faker::Lorem.word + rand(999_999).to_s }
    vanity_url  { Faker::Lorem.word + rand(999_999).to_s }
    description { Faker::Lorem.sentence }
    uuid { Faker::Code.isbn }
    before(:create) { |instance| instance.editor_account = create(:admin) }
    user_count 1
    association :logo
    association :organization
    after(:create) { |instance| instance.update_attributes(best_analysis: create(:analysis, project: instance)) }

    factory :project_with_invalid_description do
      description { Faker::Lorem.characters(820) }
      to_create { |instance| instance.save(validate: false) }
    end

    factory :project_with_big_summary do
      description { Faker::Lorem.characters(850) }
    end

    factory :project_with_less_summary do
      description { Faker::Lorem.characters(420) }
    end
  end

  factory :plain_project, class: :Project do
    name        { Faker::Lorem.word + rand(999_999).to_s }
    vanity_url  { Faker::Lorem.word + rand(999_999).to_s }
    description { Faker::Lorem.sentence }
    uuid { Faker::Code.isbn }
    before(:create) { |instance| instance.editor_account = create(:admin) }
    user_count 1
  end
end
