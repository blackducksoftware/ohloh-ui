# frozen_string_literal: true

FactoryBot.define do
  factory :analysis do
    association :project
    association :main_language, factory: :language
    markup_total { 100 }
    logic_total { 101 }
    build_total { 102 }
    first_commit_time { 1.year.ago }
    min_month { Date.current - 1.month }
    max_month { Date.current - 1.day }
    last_commit_time { 1.day.ago }
    after(:create) do |instance|
      instance.update(thirty_day_summary: create(:thirty_day_summary, analysis: instance))
      instance.update(twelve_month_summary: create(:twelve_month_summary, analysis: instance))
      prev = create(:previous_twelve_month_summary, analysis: instance)
      instance.update(previous_twelve_month_summary: prev)
      instance.update(all_time_summary: create(:all_time_summary, analysis: instance))
    end

    factory :analysis_with_multiple_activity_facts do
      transient do
        activity_facts_count { 3 }
      end

      after(:create) do |analysis, evaluator|
        create_list(:activity_fact, evaluator.activity_facts_count, analysis: analysis)
      end
    end
  end
end
