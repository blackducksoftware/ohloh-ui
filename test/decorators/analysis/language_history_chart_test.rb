# frozen_string_literal: true

require 'test_helper'

class Analysis::LanguageHistoryChartTest < ActiveSupport::TestCase
  let(:activity_fact) do
    fact_values = { code_added: 10, code_removed: 5, comments_added: 20, comments_removed: 10, on_trunk: true,
                    blanks_added: 10, blanks_removed: 7, month: 2.months.ago.beginning_of_month.advance(days: 5) }
    create(:activity_fact, fact_values)
  end

  describe 'data' do
    it 'should return chart data' do
      AllMonth.delete_all
      date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.current].map(&:beginning_of_month)
      date_range.each { |date| create(:all_month, month: date) }
      time_integer = AllMonth.all.to_a.last.month.utc.to_i * 1000

      data = Analysis::LanguageHistoryChart.new(activity_fact.analysis).data

      data['series'].first['name'].must_equal activity_fact.language.nice_name
      data['series'].first['color'].must_equal '#EEE'
      data['series'].first['data'].must_equal [[time_integer, 5]]
    end
  end
end
