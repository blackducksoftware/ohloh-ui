require 'test_helper'

class Analysis::CommitHistoryTest < ActiveSupport::TestCase
  describe 'execute' do
    it 'must return a list of dates in a range and commits' do
      analysis_sloc_set = FactoryGirl.create(:analysis_sloc_set, as_of: 1)
      commit = FactoryGirl.create(:commit, code_set: analysis_sloc_set.sloc_set.code_set, position: 0)
      analysis = analysis_sloc_set.analysis
      analysis_alias = FactoryGirl.create(:analysis_alias, commit_name: commit.name, analysis: analysis)
      name_id = analysis_alias.preferred_name_id

      date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.today].map(&:beginning_of_month)
      date_range.each do |date|
        FactoryGirl.create(:all_month, month: date)
      end

      query_options = { analysis: analysis, name_id: name_id, start_date: 3.months.ago, end_date: Date.today }
      query = Analysis::CommitHistory.new(query_options)
      results = query.execute

      results.count.must_equal 4
      results.map(&:month).must_equal date_range
      results.map(&:commits).must_equal [0, 0, 0, 1]
    end
  end
end
