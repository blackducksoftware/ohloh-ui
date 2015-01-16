FactoryGirl.define do
  factory :permission do
    association :target, factory: :project
    before(:create) { |instance| instance.editor_account = Account.find(1) }
  end
end
