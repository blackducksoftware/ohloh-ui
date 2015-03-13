FactoryGirl.define do
  factory :commit_flag do
    association :commit
    association :sloc_set
    time { Time.now }
    type 'CommitFlag::NewLanguage'
    data { { language_id: create(:language).id } }
  end
end
