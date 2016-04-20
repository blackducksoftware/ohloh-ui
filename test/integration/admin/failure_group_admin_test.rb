require 'test_helper'

class FailureGroupAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'should render index page' do
    create(:failure_group)
    login_as admin
    get admin_failure_groups_path
    assert_response :ok
  end

  it 'should render uncategorized index page' do
    create(:failure_group)
    login_as admin
    get admin_jobs_path(scope: 'uncategorized_failed_jobs')
    assert_response :ok
  end

  it 'should show failure group jobs' do
    failure_group = create(:failure_group)
    create(:failed_job, failure_group_id: failure_group.id)
    login_as admin
    get admin_failure_group_jobs_path(failure_group)
    assert_response :ok
  end

  describe 'decategorize' do
    it 'should decategorize failure groups ' do
      failure_group = create(:failure_group)
      create(:failed_job, failure_group_id: failure_group.id, exception: 'abort')
      login_as admin
      failure_group.jobs.count.must_equal 1
      get decategorize_admin_failure_group_path(failure_group.id)
      failure_group.reload.jobs.count.must_equal 0
    end

    it 'should not decategorize other failure group jobs' do
      failure_group = create(:failure_group)
      failure_group1 = create(:failure_group, pattern: '%Exception%')
      create(:failed_job, failure_group_id: failure_group.id, exception: 'abort')
      create(:failed_job, failure_group_id: failure_group1.id, exception: 'abort')
      login_as admin
      failure_group.jobs.count.must_equal 1
      failure_group1.jobs.count.must_equal 1
      get decategorize_admin_failure_group_path(failure_group.id)
      failure_group.reload.jobs.count.must_equal 0
      failure_group1.reload.jobs.count.must_equal 1
    end
  end

  describe 'categorize' do
    it 'should categorize failure_groups' do
      create(:failure_group)
      job = create(:failed_job, exception: 'abort')
      login_as admin
      job.failure_group_id.must_equal nil
      get categorize_admin_failure_groups_path, {}, 'HTTP_REFERER' => admin_failure_groups_path
      job.reload.failure_group_id.wont_equal nil
    end

    it 'should not re-categorize already categorized jobs' do
      failure_group = create(:failure_group, priority: 100)
      failure_group1 = create(:failure_group, priority: 30)
      job = create(:failed_job, exception: 'abort')
      job1 = create(:failed_job, exception: 'abort', failure_group_id: failure_group1.id)
      login_as admin
      job.failure_group_id.must_equal nil
      job1.failure_group_id.must_equal failure_group1.id
      get categorize_admin_failure_groups_path, {}, 'HTTP_REFERER' => admin_failure_groups_path
      job.reload.failure_group_id.must_equal failure_group.id
      job1.reload.failure_group_id.must_equal failure_group1.id
    end
  end

  describe 'recategorize' do
    it 'should recategorize failure_groups' do
      create(:failure_group)
      job = create(:failed_job, exception: 'abort')
      login_as admin
      job.failure_group_id.must_equal nil
      get recategorize_admin_failure_groups_path, {}, 'HTTP_REFERER' => admin_failure_groups_path
      job.reload.failure_group_id.wont_equal nil
    end

    it 'should re-categorize even if job has been aleady categorized' do
      failure_group = create(:failure_group, priority: 100)
      failure_group1 = create(:failure_group, priority: 30)
      job = create(:failed_job, exception: 'abort')
      job1 = create(:failed_job, exception: 'abort', failure_group_id: failure_group1.id)
      login_as admin
      job.failure_group_id.must_equal nil
      job1.failure_group_id.must_equal failure_group1.id
      get recategorize_admin_failure_groups_path, {}, 'HTTP_REFERER' => admin_failure_groups_path
      job.reload.failure_group_id.must_equal failure_group.id
      job1.reload.failure_group_id.must_equal failure_group.id
    end
  end

  describe 'destroy' do
    it 'should destroy the failure group' do
      failure_group = create(:failure_group)
      login_as admin
      FailureGroup.count.must_equal 1
      delete admin_failure_group_path(failure_group)
      FailureGroup.count.must_equal 0
    end

    it 'should decategorize if jobs associated with failure group' do
      failure_group = create(:failure_group)
      job = create(:failed_job, failure_group_id: failure_group.id, exception: 'abort')
      login_as admin
      FailureGroup.count.must_equal 1
      delete admin_failure_group_path(failure_group)
      FailureGroup.count.must_equal 0
      job.reload.failure_group_id.must_equal nil
    end
  end
end
