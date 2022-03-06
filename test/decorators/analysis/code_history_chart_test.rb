# frozen_string_literal: true

require 'test_helper'

class Analysis::CodeHistoryChartTest < ActiveSupport::TestCase
  let(:activity_fact) do
    fact_values = { code_added: 10, code_removed: 5, comments_added: 20, comments_removed: 10,
                    blanks_added: 10, blanks_removed: 7, month: 2.months.ago.beginning_of_month }
    create(:activity_fact, fact_values)
  end

  let(:analysis) { activity_fact.analysis }
  let(:chart) { Analysis::CodeHistoryChart.new(analysis) }

  before do
    AllMonth.delete_all
    create(:all_month, month: 2.months.ago.beginning_of_month)
    analysis.update(min_month: 3.months.ago.beginning_of_month)

    @time_integer = AllMonth.all.to_a.last.month.utc.to_i * 1000
  end

  describe 'data' do
    it 'should return code_history chart data' do
      series = chart.data['series']

      _(series.first['id']).must_equal 'code'
      _(series.map { |d| d['data'].last }).must_equal [[@time_integer, 5], [@time_integer, 10], [@time_integer, 3]]
      _(series.map { |d| d['name'] }).must_equal %w[Code Comments Blanks]
      _(chart.data['scrollbar']).must_be_nil
    end
  end

  describe 'data_for_lines_of_code' do
    it 'should return code_history chart data' do
      data = chart.data_for_lines_of_code
      series = chart.data_for_lines_of_code['series']

      _(series.first['id']).must_equal 'code'
      _(series.map { |d| d['name'] }).must_equal %w[Code Comments Blanks]
      _(series.map { |d| d['data'].last }).must_equal [[@time_integer, 5], [@time_integer, 10], [@time_integer, 3]]
      _(data['scrollbar']['enabled']).must_equal false
    end
  end
end
