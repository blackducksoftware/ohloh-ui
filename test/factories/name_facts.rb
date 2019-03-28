FactoryBot.define do
  factory :name_fact do
    association :analysis
    association :name
    association :primary_language, factory: :language
    type { 'ContributorFact' }
  end

  factory :vita_fact do
    association :analysis
    association :name
    association :primary_language, factory: :language
    type { 'VitaFact' }
    first_checkin { Time.current - 3.days }
    last_checkin { Time.current - 1.day }
  end
end
