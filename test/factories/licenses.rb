FactoryGirl.define do
  sequence :license_name do |n|
    "name-#{n}"
  end

  sequence :license_url do |n|
    "url-#{n}"
  end

  sequence :license_nice_name do |n|
    "nice_name-#{n}"
  end

  sequence :license_abbreviation do |n|
    "abbreviation-#{n}"
  end

  factory :license do
    name         { generate(:license_name) }
    url          { generate(:license_url) }
    nice_name    { generate(:license_nice_name) }
    abbreviation { generate(:license_abbreviation) }
    description Faker::Lorem.sentence
    before(:create) { |instance| instance.editor_account = Account.find(1) }
  end
end
