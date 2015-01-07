FactoryGirl.define do
  sequence :project_name do |n|
    "name-#{n}"
  end

  sequence :project_url_name do |n|
    "url_name-#{n}"
  end

  factory :project do
    name        { generate(:project_name) }
    url_name    { generate(:project_url_name) }
    description Faker::Lorem.sentence
    before(:create) { |instance| instance.editor_account = Account.find(1) }
  end
end
