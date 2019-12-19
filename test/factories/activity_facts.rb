# frozen_string_literal: true

FactoryBot.define do
  factory :activity_fact do
    association :name
    association :language
    analysis
    month { Date.current }
    code_added { 100 }
    code_removed { 100 }
    comments_added { 100 }
    comments_removed { 100 }
    blanks_added { 100 }
    blanks_removed { 100 }
    commits { 100 }
  end
end
