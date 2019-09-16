# frozen_string_literal: true

require 'test_helper'

class Analysis::ContributorHistoryChartTest < ActiveSupport::TestCase
  let(:beginning_of_month) { Time.current.beginning_of_month }
  let(:activity_fact) { create(:activity_fact, month: Date.current + 1.day) }

  before do
    AllMonth.delete_all
    date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.current].map(&:beginning_of_month)
    date_range.each { |date| create(:all_month, month: date) }
    @time_integer = AllMonth.all.to_a.last.month.utc.to_i * 1000
  end

  describe 'data' do
    it 'should return code_history chart data' do
      activity_fact.analysis.update_attribute(:created_at, Date.current + 32.days)
      create(:activity_fact, month: beginning_of_month, analysis: activity_fact.analysis)
      data = Analysis::ContributorHistoryChart.new(activity_fact.analysis).data

      data['series'].first['data'].last.must_equal [@time_integer, 1]
      data['series'].last['data'].last['x'].must_equal @time_integer
      data['series'].last['data'].last['y'].must_equal 1
    end
  end

  describe 'data_without_auxillaries' do
    it 'should return code_history chart data with auxillaries disabled' do
      activity_fact.analysis.update_attribute(:created_at, Date.current + 32.days)
      create(:activity_fact, month: beginning_of_month, analysis: activity_fact.analysis)
      data = Analysis::ContributorHistoryChart.new(activity_fact.analysis).data_without_auxillaries

      data['series'].first['data'].last.must_equal [@time_integer, 1]
      data['series'].last['data'].last['x'].must_equal @time_integer
      data['series'].last['data'].last['y'].must_equal 1
      data['rangeSelector']['enabled'].must_equal false
      data['legend']['enabled'].must_equal false
      data['scrollbar']['enabled'].must_equal false
    end
  end
end
