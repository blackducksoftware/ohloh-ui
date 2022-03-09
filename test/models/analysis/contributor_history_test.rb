# frozen_string_literal: true

require 'test_helper'

class Analysis::ContributorHistoryTest < ActiveSupport::TestCase
  describe 'execute' do
    let(:activity_fact) { create(:activity_fact, month: 2.months.ago.beginning_of_month) }

    before do
      date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.current].map(&:beginning_of_month)
      date_range.each { |date| create(:all_month, month: date) }
    end

    describe 'contributors count' do
      it 'must count activity_facts with the same analysis_id but different name_id together' do
        create(:activity_fact, month: 2.months.ago.beginning_of_month,
                               analysis: activity_fact.analysis)
        results = Analysis::ContributorHistory.new(analysis: activity_fact.analysis).execute

        _(results.map(&:contributors)).must_equal [0, 2, 0, 0]
      end

      it 'wont count activity facts with the same name_id' do
        create(:activity_fact, month: 2.months.ago.beginning_of_month, name: activity_fact.name,
                               analysis: activity_fact.analysis)
        results = Analysis::ContributorHistory.new(analysis: activity_fact.analysis).execute

        _(results.map(&:contributors)).must_equal [0, 1, 0, 0]
      end

      it 'must return zero values when no activity fact' do
        activity_fact.update!(month: nil)
        results = Analysis::ContributorHistory.new(analysis: activity_fact.analysis).execute
        _(results.map(&:contributors)).must_equal [0, 0, 0, 0]
      end
    end

    describe 'date range' do
      it 'must produce results only after the given start_date' do
        results = Analysis::ContributorHistory.new(analysis: activity_fact.analysis,
                                                   start_date: 1.month.ago).execute

        _(results.map(&:contributors)).must_equal [0, 0]
      end

      it 'must produce results only before the given end_date' do
        results = Analysis::ContributorHistory.new(analysis: activity_fact.analysis,
                                                   end_date: 3.months.ago).execute

        _(results.map(&:contributors).find { |count| count == 1 }).must_be_nil
      end

      it 'must produce results considering the given dates and all_month range' do
        results = Analysis::ContributorHistory.new(analysis: activity_fact.analysis,
                                                   start_date: 5.months.ago,
                                                   end_date: 2.months.ago).execute

        _(results.map(&:contributors)).must_equal [0, 1]
      end

      it 'wont consider activity_fact with a non beginning month date' do
        activity_fact.update!(month: 2.months.ago.beginning_of_month.advance(days: 5))
        results = Analysis::ContributorHistory.new(analysis: activity_fact.analysis).execute
        _(results.map(&:contributors)).must_equal [0, 0, 0, 0]
      end
    end
  end
end
