FactoryBot.define do
  factory :enlistment do
    association :project
    association :code_location
    deleted false
    before(:create) { |instance| instance.editor_account = create(:admin) }
  end

  # trait :ent_branch do
  #   association :repository, :branch
  # end

  # trait :ent_module do
  #   association :repository, :module
  # end

  # trait :ent_no_branch_module do
  #   association :repository, :no_branch_module
  # end
end
