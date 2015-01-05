FactoryGirl.define do
  sequence :project_name do |n|
    "OpenSourceProject#{n}"
  end

  factory :project do
    description 'An Open Source Project'
    name { generate(:project_name) }
    before(:create) { |instance| instance.editor_account = Account.find(1) }
  end
end
