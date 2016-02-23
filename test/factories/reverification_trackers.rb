FactoryGirl.define do 
  factory :reverification_tracker do
    status 'initial'
    created_at DateTime.now.utc
    updated_at DateTime.now.utc
  end
end