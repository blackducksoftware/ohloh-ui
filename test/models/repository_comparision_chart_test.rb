require 'test_helper'

class RepositoryComparisionChartTest < ActiveSupport::TestCase
  describe 'build' do
    it 'must combine repository data with default values' do
      RepositoryComparisionChart.stubs(:combine_svn_and_svn_sync_count).returns([])
      data = RepositoryComparisionChart.build.with_indifferent_access

      data[:plotOptions].must_be :present?
      data[:credits].must_be :present?
      data[:series][0][:data].wont_be_nil
    end
  end

  describe 'chart_data' do
    it 'must return a single count for Subversion' do
      create(:repository, type: 'SvnRepository')
      create(:repository, type: 'SvnRepository')
      create(:repository, type: 'SvnSyncRepository')
      create(:repository, type: 'GitRepository')
      create(:repository, type: 'GitRepository')
      create(:repository, type: 'CvsRepository')
      create(:repository, type: 'BzrRepository')
      create(:repository, type: 'HgRepository')

      expected_result = [[:Bazaar, 1], [:CVS, 1], [:Git, 2], [:Mercurial, 1], [:Subversion, 3]]
      RepositoryComparisionChart.chart_data.must_equal expected_result
    end
  end

  describe 'combine_svn_and_svn_sync_count' do
    it 'must combine svn and svn_sync data into a single unit' do
      data = [{ type: 'SvnRepository', count: 3 }, { type: 'SvnSyncRepository', count: 2 }]

      expected_result = [{ type: 'SvnRepository', count: 5 }]
      RepositoryComparisionChart.combine_svn_and_svn_sync_count(data).must_equal expected_result
    end
  end
end
