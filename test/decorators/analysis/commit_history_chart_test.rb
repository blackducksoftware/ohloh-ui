require 'test_helper'

class Analysis::CommitHistoryChartTest < ActiveSupport::TestCase
  describe 'data' do
    it 'should return code_history chart data' do
      AllMonth.delete_all
      analysis_sloc_set = create(:analysis_sloc_set, as_of: 1)
      commit = create(:commit, code_set: analysis_sloc_set.sloc_set.code_set, position: 0)
      analysis = analysis_sloc_set.analysis
      analysis.update_attribute(:created_at, Date.today + 32.days)
      create(:analysis_alias, commit_name: commit.name, analysis: analysis)

      date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.today].map(&:beginning_of_month)
      date_range.each { |date| create(:all_month, month: date) }

      time_integer = AllMonth.all.to_a.last.month.utc.to_i * 1000
      data = Analysis::CommitHistoryChart.new(analysis.reload).data

      data['rangeSelector']['enabled'].must_equal false
      data['legend']['enabled'].must_equal false
      data['scrollbar']['enabled'].must_equal false
      data['series'].first['data'].last.must_equal [time_integer, 1]
      data['series'].last['data'].last['x'].must_equal time_integer
      data['series'].last['data'].last['y'].must_equal 1
    end
  end
end
