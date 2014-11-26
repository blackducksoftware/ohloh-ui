FactoryGirl.define do
  factory :api_key do
    account_id 1
    description "An API Key for account #1"
    name "ApiKeyForAccount1"
    terms true
  end
end
