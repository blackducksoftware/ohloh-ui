FactoryGirl.define do 
  factory :account_reverification do
    status 'initial'
    created_at Time.now.utc
    updated_at Time.now.utc
  end
end