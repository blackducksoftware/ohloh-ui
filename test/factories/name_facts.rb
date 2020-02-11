# frozen_string_literal: true

FactoryBot.define do
  factory :name_fact do
    association :analysis
    association :name
    association :primary_language, factory: :language
    type { 'ContributorFact' }
  end

  factory :account_analysis_fact do
    association :analysis
    association :name
    association :primary_language, factory: :language
    type { 'AccountAnalysisFact' }
    first_checkin { Time.current - 3.days }
    last_checkin { Time.current - 1.day }
  end
end
