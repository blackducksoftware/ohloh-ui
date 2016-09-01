FactoryGirl.define do
  factory :project_security_set do
    uuid { SecureRandom.uuid }
    etag { SecureRandom.hex }
    association :project
  end
end
