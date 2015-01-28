FactoryGirl.define do
  factory :domain_blacklist do
    domain { Faker::Internet.domain_name }
  end
end
