FactoryBot.define do
  factory :organization do
    name        { Faker::Company.name + rand(999_999).to_s }
    vanity_url  { Faker::Lorem.word + rand(999_999).to_s }
    description { Faker::Lorem.sentence }
    org_type { 1 }
    before(:create) { |instance| instance.editor_account = create(:admin) }
  end
end
