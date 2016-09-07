FactoryGirl.define do
  factory :release do
    kb_release_id { Faker::Lorem.word }
  end
end
