# frozen_string_literal: true

require 'test_helper'

class FailureGroupAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'should render index page' do
    create(:failure_group)
    login_as admin
    get admin_failure_groups_path
    assert_response :ok
  end

  describe 'index' do
    it 'should render failure groups sorted in ascending order' do
      failure_group = create(:failure_group)
      create(:failed_project_analysis_job, failure_group_id: failure_group.id)
      login_as admin
      get admin_failure_groups_path(order: 'job_count_asc')
      assert_response :ok
    end

    it 'should render failure groups sorted in descending order' do
      failure_group = create(:failure_group)
      create(:failed_project_analysis_job, failure_group_id: failure_group.id)
      login_as admin
      get admin_failure_groups_path(order: 'job_count_desc')
      assert_response :ok
    end
  end

  describe 'decategorize' do
    it 'should decategorize failure groups ' do
      failure_group = create(:failure_group)
      create(:failed_project_analysis_job, failure_group_id: failure_group.id, exception: 'abort')
      login_as admin
      _(failure_group.jobs.count).must_equal 1
      get decategorize_admin_failure_group_path(failure_group.id)
      _(failure_group.reload.jobs.count).must_equal 0
    end

    it 'should not decategorize other failure group jobs' do
      failure_group = create(:failure_group)
      failure_group1 = create(:failure_group, pattern: '%Exception%')
      create(:failed_project_analysis_job, failure_group_id: failure_group.id, exception: 'abort')
      create(:failed_project_analysis_job, failure_group_id: failure_group1.id, exception: 'abort')
      login_as admin
      _(failure_group.jobs.count).must_equal 1
      _(failure_group1.jobs.count).must_equal 1
      get decategorize_admin_failure_group_path(failure_group.id)
      _(failure_group.reload.jobs.count).must_equal 0
      _(failure_group1.reload.jobs.count).must_equal 1
    end
  end

  describe 'categorize' do
    it 'should categorize failure_groups' do
      create(:failure_group)
      job = create(:failed_project_analysis_job, exception: 'abort')
      login_as admin
      _(job.failure_group_id).must_be_nil
      get categorize_admin_failure_groups_path, headers: { 'HTTP_REFERER' => admin_failure_groups_path }
      _(job.reload.failure_group_id).wont_equal nil
    end

    it 'should not re-categorize already categorized jobs' do
      failure_group = create(:failure_group, priority: 100)
      failure_group1 = create(:failure_group, priority: 30)
      job = create(:failed_project_analysis_job, exception: 'abort')
      job1 = create(:failed_project_analysis_job, exception: 'abort', failure_group_id: failure_group1.id)
      login_as admin
      _(job.failure_group_id).must_be_nil
      _(job1.failure_group_id).must_equal failure_group1.id
      get categorize_admin_failure_groups_path, headers: { 'HTTP_REFERER' => admin_failure_groups_path }
      _(job.reload.failure_group_id).must_equal failure_group.id
      _(job1.reload.failure_group_id).must_equal failure_group1.id
    end
  end

  describe 'recategorize' do
    it 'should recategorize failure_groups' do
      create(:failure_group)
      job = create(:failed_project_analysis_job, exception: 'abort')
      login_as admin
      _(job.failure_group_id).must_be_nil
      get recategorize_admin_failure_groups_path, headers: { 'HTTP_REFERER' => admin_failure_groups_path }
      _(job.reload.failure_group_id).wont_equal nil
    end

    it 'should re-categorize even if job has been aleady categorized' do
      failure_group = create(:failure_group, priority: 100)
      failure_group1 = create(:failure_group, priority: 30)
      job = create(:failed_project_analysis_job, exception: 'abort')
      job1 = create(:failed_project_analysis_job, exception: 'abort', failure_group_id: failure_group1.id)
      login_as admin
      _(job.failure_group_id).must_be_nil
      _(job1.failure_group_id).must_equal failure_group1.id
      get recategorize_admin_failure_groups_path, headers: { 'HTTP_REFERER' => admin_failure_groups_path }
      _(job.reload.failure_group_id).must_equal failure_group.id
      _(job1.reload.failure_group_id).must_equal failure_group.id
    end
  end

  describe 'destroy' do
    it 'should destroy the failure group' do
      failure_group = create(:failure_group)
      login_as admin
      _(FailureGroup.count).must_equal 1
      delete admin_failure_group_path(failure_group)
      _(FailureGroup.count).must_equal 0
    end

    it 'should decategorize if jobs associated with failure group' do
      failure_group = create(:failure_group)
      job = create(:failed_project_analysis_job, failure_group_id: failure_group.id, exception: 'abort')
      login_as admin
      _(FailureGroup.count).must_equal 1
      delete admin_failure_group_path(failure_group)
      _(FailureGroup.count).must_equal 0
      _(job.reload.failure_group_id).must_be_nil
    end
  end

  describe '.ransackable_associations' do
    it 'should return authorizable ransackable associations' do
      expected_associations = %w[jobs failed_jobs exceptions]
      FailureGroup.expects(:authorizable_ransackable_associations).returns(expected_associations)

      result = FailureGroup.ransackable_associations
      _(result).must_equal expected_associations
    end

    it 'should accept auth_object parameter' do
      auth_object = { user: 'admin', role: 'manager' }
      FailureGroup.expects(:authorizable_ransackable_associations).returns(['jobs'])

      result = FailureGroup.ransackable_associations(auth_object)
      _(result).must_equal ['jobs']
    end

    it 'should ignore auth_object parameter value' do
      auth_objects = [nil, 'admin', { role: 'user' }, 12_345, true, false]

      auth_objects.each do |auth_obj|
        FailureGroup.expects(:authorizable_ransackable_associations).returns(['jobs']).once

        result = FailureGroup.ransackable_associations(auth_obj)
        _(result).must_equal ['jobs']
      end
    end
  end

  describe 'decategorize' do
    it 'shows decategorize link on show page' do
      login_as admin
      @failure_group = create(:failure_group)
      get admin_failure_group_path(@failure_group)
      assert_response :success
      assert_select 'a[href=?]', decategorize_admin_failure_group_path(@failure_group.id), text: 'Decategorize'
    end
  end
end
