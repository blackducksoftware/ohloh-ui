FactoryGirl.define do
  factory :organization do
    name        { Faker::Company.name }
    url_name    { Faker::Lorem.word + rand(999_999).to_s }
    description { Faker::Lorem.sentence }
    org_type 1
    before(:create) { |instance| instance.editor_account = create(:admin) }
  end
end
