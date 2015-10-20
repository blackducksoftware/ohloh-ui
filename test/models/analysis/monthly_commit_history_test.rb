require 'test_helper'

class Analysis::MonthlyCommitHistoryTest < ActiveSupport::TestCase
  describe 'execute' do
    it 'must generate the expected data' do
      analysis_sloc_set = create(:analysis_sloc_set, as_of: 1)
      commit = create(:commit, code_set: analysis_sloc_set.sloc_set.code_set, position: 0)
      analysis = analysis_sloc_set.analysis
      analysis_alias = create(:analysis_alias, commit_name: commit.name, analysis: analysis)
      name_id = analysis_alias.preferred_name_id

      date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.today].map(&:beginning_of_month)
      date_range.each do |date|
        FactoryGirl.create(:all_month, month: date)
      end

      query_options = { analysis: analysis, name_id: name_id, start_date: 3.months.ago, end_date: Date.today }
      query = Analysis::MonthlyCommitHistory.new(query_options)
      results = query.execute

      results.count.must_equal 4
      results.map { |r| r[:this_month] }.must_equal date_range.map { |d| d.strftime('%F %T') }
      results.map { |r| r[:count] }.must_equal %w(0 0 0 1)
    end
  end
end
