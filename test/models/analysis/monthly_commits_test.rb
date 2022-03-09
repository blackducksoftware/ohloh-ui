# frozen_string_literal: true

require 'test_helper'

class MonthlyCommitsTest < ActiveSupport::TestCase
  describe 'execute' do
    before do
      date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.current].map(&:beginning_of_month)
      date_range.each do |date|
        FactoryBot.create(:all_month, month: date)
      end
    end

    it 'must return a list of months and commit count' do
      monthly_commit_history = create(:monthly_commit_history, json: "{\"#{2.months.ago.strftime('%Y-%m-01')}\" : 1}")

      results = Analysis::MonthlyCommits.new(analysis: monthly_commit_history.analysis).execute

      _(results.first.month).must_equal 3.months.ago.beginning_of_month
      _(results.map(&:commits)).must_equal [0, 1, 0, 0]
    end
  end
end
