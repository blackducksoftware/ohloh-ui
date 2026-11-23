# frozen_string_literal: true

require 'test_helper'

class FisJobTest < ActiveSupport::TestCase
  describe 'ransackable_attributes' do
    it 'should return authorizable ransackable attributes' do
      FisJob.expects(:authorizable_ransackable_attributes).returns(%w[status type])
      result = FisJob.ransackable_attributes
      _(result).must_equal %w[status type]
    end
  end

  describe 'ransackable_associations' do
    it 'should return authorizable ransackable associations' do
      FisJob.expects(:authorizable_ransackable_associations).returns(%w[project worker])
      result = FisJob.ransackable_associations
      _(result).must_equal %w[project worker]
    end
  end

  describe 'stale_jobs_report' do
    it 'should return empty report when no stale jobs and no dnf source' do
      enlistments = Enlistment.none
      enlistments.stubs(:exists?).returns(false)
      FisJob.stubs(:incomplete_fis_jobs).returns(FisJob.none)

      result = FisJob.stale_jobs_report(enlistments)
      _(result).must_equal({})
    end

    it 'should include dnf_present when do_not_fetch source exists' do
      enlistments = Enlistment.none
      enlistments.stubs(:exists?).returns(true)
      FisJob.stubs(:incomplete_fis_jobs).returns(FisJob.none)

      result = FisJob.stale_jobs_report(enlistments)
      _(result).must_equal({ dnf_present: 1 })
    end

    it 'should include failure group names for incomplete jobs' do
      # Reset memoized value
      FisJob.instance_variable_set(:@failure_group_patterns, nil)

      failure_group = create(:failure_group, name: 'Connection Reset by Peer')
      enlistments = Enlistment.none
      enlistments.stubs(:exists?).returns(false)

      incomplete_scope = stub
      incomplete_scope.stubs(:where).returns(stub(pluck: [failure_group.id]))
      FisJob.stubs(:incomplete_fis_jobs).returns(incomplete_scope)

      result = FisJob.stale_jobs_report(enlistments)
      _(result['connection_reset_by_peer']).must_equal 1
    end

    it 'should skip nil failure group names' do
      enlistments = Enlistment.none
      enlistments.stubs(:exists?).returns(false)

      incomplete_scope = stub
      incomplete_scope.stubs(:where).returns(stub(pluck: [999_999]))
      FisJob.stubs(:incomplete_fis_jobs).returns(incomplete_scope)

      # Reset memoized value
      FisJob.instance_variable_set(:@failure_group_patterns, nil)
      result = FisJob.stale_jobs_report(enlistments)
      _(result).must_equal({})
    end
  end

  describe 'underscore_and_clean' do
    it 'should convert name with parentheses to underscored format' do
      result = FisJob.send(:underscore_and_clean, 'Connection Reset by Peer (SVN?)')
      _(result).must_equal 'connection_reset_by_peer'
    end

    it 'should handle simple names' do
      result = FisJob.send(:underscore_and_clean, 'Investigate')
      _(result).must_equal 'investigate'
    end
  end
end
