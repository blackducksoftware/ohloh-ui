# frozen_string_literal: true

require 'test_helper'

class Analysis::LanguageHistoryChartTest < ActiveSupport::TestCase
  let(:activity_fact) do
    fact_values = { code_added: 10, code_removed: 5, comments_added: 20, comments_removed: 10, on_trunk: true,
                    blanks_added: 10, blanks_removed: 7, month: 2.months.ago.beginning_of_month }
    create(:activity_fact, fact_values)
  end

  describe 'data' do
    it 'should return chart data' do
      AllMonth.delete_all
      create(:all_month, month: 2.months.ago.beginning_of_month)
      time_integer = AllMonth.all.to_a.last.month.utc.to_i * 1000
      activity_fact.analysis.update(min_month: 3.months.ago.beginning_of_month)

      data = Analysis::LanguageHistoryChart.new(activity_fact.analysis).data

      _(data['series'].first['name']).must_equal activity_fact.language.nice_name
      _(data['series'].first['color']).must_equal '#EEE'
      _(data['series'].first['data']).must_equal [[time_integer, 5]]
    end
  end
end
