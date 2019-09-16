# frozen_string_literal: true

FactoryBot.define do
  factory :factoid do
    association :analysis
    association :language
    association :license
    type { 'FactoidTeamSizeZero' }
    severity { -3 }
    previous_count { 0 }
    current_count { 0 }
    max_count { 0 }
  end
end
