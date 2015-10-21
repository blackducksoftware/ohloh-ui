require 'test_helper'

class Analysis::CommitHistoryTest < ActiveSupport::TestCase
  describe 'execute' do
    before do
      analysis_sloc_set = create(:analysis_sloc_set, as_of: 1)
      commit = create(:commit, code_set: analysis_sloc_set.sloc_set.code_set, position: 0)
      analysis = analysis_sloc_set.analysis
      analysis_alias = create(:analysis_alias, commit_name: commit.name, analysis: analysis)
      name_id = analysis_alias.preferred_name_id

      @date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.today].map(&:beginning_of_month)
      @date_range.each do |date|
        FactoryGirl.create(:all_month, month: date)
      end

      @query_options = { analysis: analysis, name_id: name_id, start_date: 3.months.ago, end_date: Date.today }
    end

    it 'must return a list of dates in a range and commits' do
      commit_history = Analysis::CommitHistory.new(@query_options)
      results = commit_history.execute

      results.count.must_equal 4
      results.map(&:month).must_equal @date_range
      results.map(&:commits).must_equal [0, 0, 0, 1]
    end

    it 'wont join analysis_aliases when there no name_id is passed' do
      commit_history = Analysis::CommitHistory.new(analysis: @query_options[:analysis])
      sql_query = commit_history.send(:query).to_sql

      sql_query.wont_match /INNER JOIN "?analysis_aliases/
    end
  end
end
