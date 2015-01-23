FactoryGirl.define do
  factory :project do
    name        { Faker::Lorem.word + rand(999_999).to_s }
    url_name    { Faker::Lorem.word + rand(999_999).to_s }
    description { Faker::Lorem.sentence }
    before(:create) { |instance| instance.editor_account = create(:admin) }
    user_count 1
  end
end
