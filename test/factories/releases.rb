FactoryGirl.define do
  factory :release do
    sequence :kb_release_id
    sequence :version do |n|
      "V#{n}"
    end
    released_on { Time.now.utc }
  end
end
