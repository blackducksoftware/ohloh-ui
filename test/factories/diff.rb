FactoryGirl.define do
  factory :diff do
    association :commit
    association :fyle
  end
end
