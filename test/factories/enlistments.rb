FactoryBot.define do
  factory :enlistment do
    association :project
    deleted false
    before(:create) { |instance| instance.editor_account = create(:admin) }
    before(:create) { |instance| instance.stubs(:ensure_forge_and_job) }
  end
end
