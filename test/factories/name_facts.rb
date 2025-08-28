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
    first_checkin { 3.days.ago }
    last_checkin { 1.day.ago }
  end
end
