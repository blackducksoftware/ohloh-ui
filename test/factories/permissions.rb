FactoryGirl.define do
  factory :permission do
    before(:create) { |instance| instance.editor_account = Account.find(1) }
  end
end
