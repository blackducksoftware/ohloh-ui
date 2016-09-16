require 'test_helper'

class Analysis::CodeHistoryChartTest < ActiveSupport::TestCase
  let(:activity_fact) do
    fact_values = { code_added: 10, code_removed: 5, comments_added: 20, comments_removed: 10,
                    blanks_added: 10, blanks_removed: 7, month: 2.months.ago.beginning_of_month.advance(days: 5) }
    create(:activity_fact, fact_values)
  end

  let(:analysis) { activity_fact.analysis }
  let(:chart) { Analysis::CodeHistoryChart.new(analysis) }

  before do
    AllMonth.delete_all
    date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.current].map(&:beginning_of_month)
    date_range.each do |date|
      create(:all_month, month: date)
    end

    create(:activity_fact, analysis: activity_fact.analysis)
    @time_integer = AllMonth.all.to_a.last.month.utc.to_i * 1000
  end

  describe 'data' do
    it 'should return code_history chart data' do
      series = chart.data['series']

      series.first['id'].must_equal 'code'
      series.map { |d| d['data'].last }.must_equal [[@time_integer, 5], [@time_integer, 10], [@time_integer, 3]]
      series.map { |d| d['name'] }.must_equal %w(Code Comments Blanks)
      chart.data['scrollbar'].must_equal nil
    end
  end

  describe 'data_for_lines_of_code' do
    it 'should return code_history chart data' do
      data = chart.data_for_lines_of_code
      series = chart.data_for_lines_of_code['series']

      series.first['id'].must_equal 'code'
      series.map { |d| d['name'] }.must_equal %w(Code Comments Blanks)
      series.map { |d| d['data'].last }.must_equal [[@time_integer, 5], [@time_integer, 10], [@time_integer, 3]]
      data['scrollbar']['enabled'].must_equal false
    end
  end
end
