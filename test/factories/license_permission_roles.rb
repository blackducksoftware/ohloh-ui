FactoryGirl.define do
  factory :license_permission_role do |f|
    f.association :license
    f.association :license_permission
    status 1
  end
end
