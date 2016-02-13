FactoryGirl.define do 
  factory :account_reverification do
    status 'initial'
    created_at DateTime.now.utc
    updated_at DateTime.now.utc
  end
end