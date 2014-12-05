FactoryGirl.define do
  sequence :api_key_name do |n|
    "ApiKeyForAccount#{n}"
  end

  sequence :api_key_key do |n|
    "ApiKey#{n}"
  end

  factory :api_key do
    account_id 1
    description 'An API Key for account #1'
    name { generate(:api_key_name) }
    key { generate(:api_key_key) }
    terms '1'
  end
end
