# frozen_string_literal: true

require 'test_helper'

class Analysis::CommitHistoryChartTest < ActiveSupport::TestCase
  describe 'data' do
    it 'should return code_history chart data' do
      monthly_commit_history = create(:monthly_commit_history, json: "{\"#{Date.current.strftime('%Y-%m-01')}\" : 1}")
      AllMonth.delete_all
      analysis = monthly_commit_history.analysis
      analysis.update_attribute(:created_at, Date.current + 32.days)

      date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.current].map(&:beginning_of_month)
      date_range.each { |date| create(:all_month, month: date) }

      time_integer = AllMonth.all.to_a.last.month.utc.to_i * 1000
      data = Analysis::CommitHistoryChart.new(analysis.reload).data

      data['rangeSelector']['enabled'].must_equal true
      data['legend']['enabled'].must_equal false
      data['scrollbar']['enabled'].must_equal true
      data['series'].first['data'].last.must_equal [time_integer, 1]
      data['series'].last['data'].last['x'].must_equal time_integer
      data['series'].last['data'].last['y'].must_equal 1
    end
  end
end
