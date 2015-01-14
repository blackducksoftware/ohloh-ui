FactoryGirl.define do
  factory :project do
    name        { Faker::Lorem.word }
    url_name    { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    before(:create) { |instance| instance.editor_account = Account.find(1) }
  end
end
