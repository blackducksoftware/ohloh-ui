FactoryGirl.define do
  factory :vulnerability do
    sequence :cve_id
    generated_on { 1.year.ago }
    published_on { 1.year.ago }
    severity { rand(0..2) }
  end
end
