def random_repository_name
  chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + ['_', '-', '+', '/', '.']
  (0...16).map { chars[rand(chars.length)] }.join
end

FactoryBot.define do
  factory :code_location do
    association :repository
    module_branch_name { random_repository_name }
    bypass_url_validation true
    after(:create) do |code_location|
      create(:enlistment, code_location: code_location)
    end

    trait :validate do
      bypass_url_validation nil
    end

    trait :with_code_set_and_sloc_set do
      after(:create) do |code_location|
        code_set = create(:code_set, code_location: code_location, as_of: 2, best_sloc_set: create(:sloc_set, as_of: 1))
        code_location.update_attribute(:best_code_set, code_set)
      end
    end

    trait :with_code_set do
      after(:create) do |code_location|
        code_set = create(:code_set, code_location: code_location)
        code_location.update_attribute(:best_code_set, code_set)
      end
    end
  end
end
