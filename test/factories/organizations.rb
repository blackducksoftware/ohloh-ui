FactoryGirl.define do
  sequence :organization_name do |n|
    "name-#{n}"
  end

  sequence :organization_url_name do |n|
    "url_name-#{n}"
  end

  factory :organization do
    name        { generate(:organization_name) }
    url_name    { generate(:organization_url_name) }
    description Faker::Lorem.sentence
    before(:create) { |instance| instance.editor_account = Account.find(1) }
  end
end
