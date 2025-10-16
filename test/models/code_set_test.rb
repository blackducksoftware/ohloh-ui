# frozen_string_literal: true

require 'test_helper'

describe CodeSet do
  let(:clump) { create(:clump) }
  let(:code_set) { clump.code_set }

  describe 'reimport' do
    it 'should create a new code set, clump and import job' do
      # Clone the most recently updated clump, which we want to be the factory created one.
      # So make one more older GitClump to test the sort.
      # code_set.clumps << GitClump.create(slave: Slave.first)
      code_set.clumps.last.update_attribute(:updated_at, clump.updated_at - 2.days)
      Slave.any_instance.stubs(:run_local_or_remote).returns(true)

      job = code_set.reimport
      _(CodeSet.last).must_equal job.code_set
    end
  end

  describe 'ignore_prefixes' do
    it 'should ignore file names' do
      enlistment = create(:enlistment)
      code_set = create(:code_set, code_location_id: enlistment.code_location_id)
      _(code_set.ignore_prefixes(enlistment.project)).must_be_empty
    end
  end

  describe 'allow_prefixes' do
    it 'should ignore file names' do
      enlistment = create(:enlistment, allowed_fyles: nil)
      code_set = create(:code_set, code_location_id: enlistment.code_location_id)
      _(code_set.allow_prefixes(enlistment.project)).must_be_empty
    end
  end

  describe '.ransackable_associations' do
    it 'should return authorizable ransackable associations' do
      expected_associations = %w[commits fyles sloc_sets clumps jobs]
      CodeSet.expects(:authorizable_ransackable_associations).returns(expected_associations)

      result = CodeSet.ransackable_associations
      _(result).must_equal expected_associations
    end

    it 'should accept auth_object parameter' do
      auth_object = { user: 'admin', role: 'manager' }
      CodeSet.expects(:authorizable_ransackable_associations).returns(['commits'])

      result = CodeSet.ransackable_associations(auth_object)
      _(result).must_equal ['commits']
    end

    it 'should ignore auth_object parameter value' do
      auth_objects = [nil, 'admin', { role: 'user' }, 12_345, true, false]

      auth_objects.each do |auth_obj|
        CodeSet.expects(:authorizable_ransackable_associations).returns(['commits']).once

        result = CodeSet.ransackable_associations(auth_obj)
        _(result).must_equal ['commits']
      end
    end
    it 'should delegate to authorizable_ransackable_associations method' do
      # Test that the method is purely a delegation
      expected_result = %w[commits fyles sloc_sets best_sloc_set]

      CodeSet.expects(:authorizable_ransackable_associations).once.returns(expected_result)

      actual_result = CodeSet.ransackable_associations('test_auth')
      _(actual_result).must_equal expected_result
    end

    it 'should handle empty associations array' do
      CodeSet.stubs(:authorizable_ransackable_associations).returns([])

      result = CodeSet.ransackable_associations
      _(result).must_equal []
    end

    it 'should maintain method signature compatibility with Ransack' do
      CodeSet.stubs(:authorizable_ransackable_associations).returns(%w[commits fyles])

      # Test method can be called with 0 arguments
      result_no_args = CodeSet.ransackable_associations
      _(result_no_args).must_be_instance_of Array

      # Test method can be called with 1 argument
      result_with_args = CodeSet.ransackable_associations('some_auth_object')
      _(result_with_args).must_be_instance_of Array

      # Both calls should return the same result
      _(result_no_args).must_equal result_with_args
    end
  end
end
