FactoryGirl.define do
  factory :project_license do
    project
    license
    before(:create) { |instance| instance.editor_account = create(:admin) }
  end
end
