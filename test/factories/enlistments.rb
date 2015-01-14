FactoryGirl.define do
  factory :enlistment do
    association :project
    association :repository
    deleted false
    before(:create) { |instance| instance.editor_account = Account.find(1) }
  end
end
