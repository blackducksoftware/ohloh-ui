FactoryGirl.define do
  factory :invite do
    association :project
    activation_code { Faker::Lorem.characters(10) }
    association :invitor, factory: :account
    invitee_email { Faker::Internet.free_email }
    contribution Contribution.first
    association :name
  end
end
