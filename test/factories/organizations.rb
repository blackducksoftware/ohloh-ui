FactoryGirl.define do
  factory :organization do
    name        { Faker::Company.name }
    url_name    { Faker::Lorem.word + rand(999_999).to_s }
    description { Faker::Lorem.sentence }
    before(:create) { |instance| instance.editor_account = Account.find(1) }
  end
end
