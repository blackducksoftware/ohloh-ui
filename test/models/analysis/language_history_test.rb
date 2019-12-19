# frozen_string_literal: true

require 'test_helper'

class Analysis::LanguageHistoryTest < ActiveSupport::TestCase
  describe 'execute' do
    let(:activity_fact) { create(:activity_fact, month: 2.months.ago.beginning_of_month, on_trunk: true) }

    before do
      dates = [3.months.ago, 2.months.ago, 1.month.ago]
      dates << Date.current unless Date.current.day == 1
      date_range = dates.map(&:beginning_of_month)
      date_range.each { |date| create(:all_month, month: date) }
    end

    it 'must return language details' do
      results = Analysis::LanguageHistory.new(analysis: activity_fact.analysis).execute
      results.first.language.must_equal activity_fact.language.nice_name
      results.first.language_name.must_equal activity_fact.language.name
    end

    it 'must return code added or removed details over multiple activity_facts' do
      activity_fact.update! code_added: 7, code_removed: 10
      create(:activity_fact, analysis: activity_fact.analysis, code_added: 5,
                             code_removed: 5)
      results = Analysis::LanguageHistory.new(analysis: activity_fact.analysis).execute
      results.first.code_total.must_equal(-3)
    end

    it 'must return comments added or removed details over multiple activity_facts' do
      activity_fact.update! comments_added: 7, comments_removed: 10
      create(:activity_fact, analysis: activity_fact.analysis, comments_added: 5,
                             comments_removed: 5)
      results = Analysis::LanguageHistory.new(analysis: activity_fact.analysis).execute
      results.first.comments_total.must_equal(-3)
    end

    it 'must return blanks added or removed details over multiple activity_facts' do
      activity_fact.update! blanks_added: 10, blanks_removed: 7
      create(:activity_fact, analysis: activity_fact.analysis, blanks_added: 5,
                             blanks_removed: 5)
      results = Analysis::LanguageHistory.new(analysis: activity_fact.analysis).execute
      results.first.blanks_total.must_equal 3
    end

    it 'wont consider months older than the activity_fact.month' do
      results = Analysis::LanguageHistory.new(analysis: activity_fact.analysis).execute
      months = results.map(&:month)
      months.find { |month| month == 2.months.ago.beginning_of_month }.wont_be_nil
      months.find { |month| month == 3.months.ago.beginning_of_month }.must_be_nil
    end

    it 'must return results within the given date range' do
      results = Analysis::LanguageHistory.new(analysis: activity_fact.analysis,
                                              start_date: 5.months.ago,
                                              end_date: 2.months.ago).execute

      results.length.must_equal 1
    end
  end
end
