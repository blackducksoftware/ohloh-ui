# frozen_string_literal: true

require 'test_helper'

class Analysis::CommitHistoryTest < ActiveSupport::TestCase
  describe 'execute' do
    before do
      monthly_commit_history = create(:monthly_commit_history, json: "{\"#{Date.current.strftime('%Y-%m-01')}\" : 1}")

      @date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.current].map(&:beginning_of_month)
      @date_range.each do |date|
        FactoryBot.create(:all_month, month: date)
      end

      @query_options = { analysis: monthly_commit_history.analysis, start_date: 3.months.ago, end_date: Date.current }
    end

    it 'must return a list of dates in a range and commits' do
      commit_history = Analysis::CommitHistory.new(@query_options)
      results = commit_history.execute

      _(results.count).must_equal 4
      _(results.map(&:month)).must_equal @date_range
      _(results.map(&:commits)).must_equal [0, 0, 0, 1]
    end
  end
end
