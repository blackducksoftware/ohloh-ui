# frozen_string_literal: true

require 'test_helper'

class JobAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'mark_as_failed should work' do
    job = create(:project_analysis_job)
    login_as admin

    get mark_as_failed_admin_job_path(job), headers: { 'HTTP_REFERER' => admin_jobs_path }

    _(job.failure_group).must_be_nil
    assert_equal flash[:notice], "Job #{job.id} marked as failed."
  end

  it 'recoount should work' do
    job = create(:project_analysis_job)
    login_as admin
    get recount_admin_job_path(job)

    assert_redirected_to admin_job_path(job)
    assert_equal job.retry_count, 0
    _(job.wait_until).must_be_nil
    assert_equal flash[:notice], "Job #{job.id} retry attempts counter has been reset to 0."
  end

  it 'should render project jobs index page for newly created project' do
    login_as admin
    create(:project_analysis_job, worker: create(:worker, id: 1))
    project = create(:project)
    enlistment = create_enlistment_with_code_location(project)
    Project.any_instance.stubs(:code_locations).returns([CodeLocation.new(id: enlistment.code_location_id)])
    VCR.use_cassette('project_jobs', match_requests_on: [:path]) do
      get oh_admin_project_jobs_path(project_id: project.vanity_url)
    end
    assert_response :success
  end

  it 'should render project index page for analses completed project' do
    Project.any_instance.stubs(:code_locations).returns([])
    login_as admin
    project = create(:project)
    create(:fetch_job, project: project, worker: create(:worker, id: 1))
    VCR.use_cassette('project_jobs', match_requests_on: [:path]) do
      get oh_admin_project_jobs_path(project_id: project.vanity_url)
    end
    assert_response :success
  end

  it 'should render project jobs index page for queued project jobs' do
    Project.any_instance.stubs(:code_locations).returns([])
    login_as admin
    project = create(:project)
    create(:worker, id: 1)

    VCR.use_cassette('project_jobs', match_requests_on: [:path]) do
      get oh_admin_project_jobs_path(project_id: project.vanity_url)
    end
    assert_response :success
  end

  it 'should render jobs show page' do
    login_as admin
    job = create(:project_analysis_job, worker: create(:worker))
    Job.any_instance.stubs(:code_location).returns(code_location_stub)
    get admin_job_path(job)
    assert_response :success
  end

  it 'should allow to reschedule' do
    login_as admin
    job = create(:project_analysis_job, worker: create(:worker))
    put reschedule_admin_job_path(job), headers: { 'HTTP_REFERER' => admin_jobs_path }
    assert_response :redirect
  end

  it 'should not allow to reschedule if job is running' do
    login_as admin
    job = create(:project_analysis_job, worker: create(:worker), status: Job::STATUS_RUNNING)
    put reschedule_admin_job_path(job), headers: { 'HTTP_REFERER' => admin_jobs_path }
    assert_response :redirect
  end

  it 'should rebuild people' do
    login_as admin
    job = create(:project_analysis_job, worker: create(:worker))
    put rebuild_people_admin_job_path(job), headers: { 'HTTP_REFERER' => admin_jobs_path }
    assert_response :redirect
  end

  it 'should update priority' do
    login_as admin
    job = create(:project_analysis_job)
    put admin_job_path(job), params: { job: { priority: 5 } }
    assert_response :redirect
  end

  it 'should update retry_count' do
    login_as admin
    job = create(:project_analysis_job)
    put admin_job_path(job), params: { job: { retry_count: 3 } }
    _(job.reload.retry_count).must_equal 3
  end

  it 'should delete job' do
    login_as admin
    job = create(:project_analysis_job)
    assert_difference 'Job.count', -1 do
      delete admin_job_path(job)
    end
    assert_response :redirect
  end

  it 'should redirect to OhAdmin for project jobs' do
    Project.any_instance.stubs(:code_locations).returns([])
    login_as admin
    project = create(:project)
    get admin_project_jobs_path(project_id: project)
    assert_response :redirect
  end
end
