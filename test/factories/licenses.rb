FactoryBot.define do
  factory :license do
    vanity_url   { Faker::Lorem.word + rand(999_999).to_s }
    url          { Faker::Internet.url }
    name         { Faker::Lorem.word + rand(999_999).to_s }
    description { Faker::Lorem.sentence }
    locked false
    before(:create) { |instance| instance.editor_account = create(:admin) }
  end
end
