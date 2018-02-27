require 'test_helper'

class RepositoryComparisionChartTest < ActiveSupport::TestCase
  describe 'build' do
    it 'must combine repository data with default values' do
      RepositoryComparisionChart.stubs(:combine_svn_count).returns([])
      CodeLocation.stubs(:scm_type_count).returns([])
      data = RepositoryComparisionChart.build.with_indifferent_access

      data[:plotOptions].must_be :present?
      data[:credits].must_be :present?
      data[:series][0][:data].wont_be_nil
    end
  end

  describe 'chart_data' do
    it 'must return a single count for Subversion' do
      WebMocker.scm_type_count([{ type: :bzr, count: 1 }, { type: :cvs, count: 1 }, { type: :git, count: 2 },
                                { type: :hg, count: 1 }, { type: :svn, count: 2 }, { type: :svn_sync, count: 1 }])
      expected_result = [[:Bazaar, 1], [:CVS, 1], [:Git, 2], [:Mercurial, 1], [:Subversion, 3]]
      RepositoryComparisionChart.chart_data.must_equal expected_result
    end
  end

  describe 'combine_svn_count' do
    it 'must combine all svn data into a single unit' do
      data = [{ type: 'svn', count: 3 }, { type: 'svn_sync', count: 2 }, { type: 'git_svn', count: 1 }]
      CodeLocation.stubs(:scm_type_count).returns(data)

      expected_result = [{ type: 'svn', count: 6 }]
      RepositoryComparisionChart.combine_svn_count(data).must_equal expected_result
    end
  end
end
