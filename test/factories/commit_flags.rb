# frozen_string_literal: true

FactoryBot.define do
  factory :commit_flag do
    association :commit
    association :sloc_set
    time { Time.current }
    type { 'CommitFlag::NewLanguage' }
    data { { language_id: create(:language).id } }
  end
end
