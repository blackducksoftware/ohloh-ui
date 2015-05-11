require 'test_helper'

class MonthlyCommitsTest < ActiveSupport::TestCase
  describe 'execute' do
    before do
      date_range = [3.months.ago, 2.months.ago, 1.month.ago, Date.today].map(&:beginning_of_month)
      date_range.each do |date|
        FactoryGirl.create(:all_month, month: date)
      end
    end

    it 'must return a list of months and commit count' do
      analysis_sloc_set = FactoryGirl.create(:analysis_sloc_set, as_of: 1)
      analysis = analysis_sloc_set.analysis

      commit = FactoryGirl.create(:commit, code_set: analysis_sloc_set.sloc_set.code_set,
                                           position: 0, time: 2.months.ago)
      create(:analysis_alias, commit_name: commit.name, analysis: analysis)

      results = Analysis::MonthlyCommits.new(analysis: analysis).execute

      results.first.month.must_equal 3.months.ago.beginning_of_month
      results.map(&:commits).must_equal [0, 1, 0, 0]
    end
  end
end
