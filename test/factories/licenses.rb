FactoryGirl.define do
  factory :license do
    name         { Faker::Lorem.word + rand(999_999).to_s }
    url          { Faker::Internet.url }
    nice_name    { Faker::Lorem.word + rand(999_999).to_s }
    abbreviation { Faker::Hacker.abbreviation }
    description { Faker::Lorem.sentence }
    before(:create) { |instance| instance.editor_account = Account.find(1) }
  end
end
