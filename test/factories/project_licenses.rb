FactoryGirl.define do
  factory :project_license do
    project
    license
    before(:create) { |instance| instance.editor_account = Account.find(1) }
  end
end
