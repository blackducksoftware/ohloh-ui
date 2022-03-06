# frozen_string_literal: true

require 'test_helper'

class LanguageFactTest < ActiveSupport::TestCase
  let(:date_range) { [3.months.ago, 2.months.ago, 1.month.ago, Date.current].map(&:beginning_of_month) }
  let(:create_all_months) do
    date_range.each { |date| create(:all_month, month: date) }
  end
  let(:language) { create(:language) }

  describe 'report' do
    it 'should return all month fact reports' do
      create(:language_fact, language: language, month: 3.months.ago.beginning_of_month, loc_changed: 25)
      create_all_months
      language_fact_report = LanguageFact.report(language)
      _(language_fact_report.length).must_equal 3
      _(language_fact_report.map(&:loc_changed)).must_equal [25, nil, nil]
      _(language_fact_report.map(&:percent)).must_equal [100.0, 0.0, 0.0]
    end

    it 'should allow start and end month' do
      create_all_months
      language_fact_report = LanguageFact.report(language, start_month: 2.months.ago.beginning_of_month,
                                                           end_month: 2.months.ago.beginning_of_month)
      _(language_fact_report.length).must_equal 1
    end

    it 'should compute for other measure types' do
      create_all_months
      create(:language_fact, language: language, month: 3.months.ago.beginning_of_month, commits: 25)
      language_fact_report = LanguageFact.report(language, measure: 'commits')
      _(language_fact_report.length).must_equal 3
      _(language_fact_report.map(&:commits)).must_equal [25, nil, nil]
      _(language_fact_report.map(&:percent)).must_equal [100.0, 0.0, 0.0]
    end
  end
end
