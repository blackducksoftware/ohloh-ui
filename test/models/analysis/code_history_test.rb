# frozen_string_literal: true

require 'test_helper'

class CodeHistoryTest < ActiveSupport::TestCase
  describe 'execute' do
    let(:activity_fact) do
      create(:activity_fact, month: 1.month.ago.beginning_of_month)
    end

    before do
      date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.current].map(&:beginning_of_month)
      date_range.each do |date|
        FactoryBot.create(:all_month, month: date)
      end
    end

    it 'must return code added or removed details over multiple activity_facts' do
      activity_fact.update! code_added: 7, code_removed: 10
      create(:activity_fact, analysis: activity_fact.analysis, code_added: 5,
                             code_removed: 5, month: Date.current.beginning_of_month)
      results = Analysis::CodeHistory.new(analysis: activity_fact.analysis).execute
      results.map(&:code_total).must_equal [nil, nil, -3, 0]
    end

    it 'must return comments added or removed details over multiple activity_facts' do
      activity_fact.update! comments_added: 7, comments_removed: 10
      create(:activity_fact, analysis: activity_fact.analysis, comments_added: 5,
                             comments_removed: 5, month: Date.current.beginning_of_month)
      results = Analysis::CodeHistory.new(analysis: activity_fact.analysis).execute
      results.map(&:comments_total).must_equal [nil, nil, -3, 0]
    end

    it 'must return blanks added or removed details over multiple activity_facts' do
      activity_fact.update! blanks_added: 10, blanks_removed: 7
      create(:activity_fact, analysis: activity_fact.analysis, blanks_added: 5,
                             blanks_removed: 5, month: Date.current.beginning_of_month)
      results = Analysis::CodeHistory.new(analysis: activity_fact.analysis).execute
      results.map(&:blanks_total).must_equal [nil, nil, 3, 0]
    end

    it 'must return nil values for months older than activity_facts.month' do
      results = Analysis::CodeHistory.new(analysis: activity_fact.analysis).execute
      results.select { |result| result.month < activity_fact.month }
             .map(&:code_total).compact.must_be :empty?
    end
  end
end
