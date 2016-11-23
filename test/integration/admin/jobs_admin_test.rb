require 'test_helper'

class CodeSetAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'mark_as_failed should work' do
    job = create(:sloc_job, code_location: create(:code_location, best_code_set: create(:code_set)))
    login_as admin

    get mark_as_failed_admin_job_path(job), {}, 'HTTP_REFERER' => admin_jobs_path

    assert_equal job.failure_group, nil
    assert_equal SlaveLog.last.job, job
    assert_equal flash[:notice], "Job #{job.id} marked as failed."
  end

  it 'recoount should work' do
    job = create(:fetch_job, code_location: create(:code_location))
    login_as admin
    get recount_admin_job_path(job)

    assert_redirected_to admin_job_path(job)
    assert_equal job.retry_count, 0
    assert_equal job.wait_until, nil
    assert_equal flash[:notice], "Job #{job.id} retry attempts counter has been reset to 0."
  end

  it 'should render index page' do
    login_as admin
    create(:fetch_job, code_location: create(:code_location), slave: create(:slave))
    get admin_jobs_path
    assert_response :success
  end

  it 'should render project jobs index page for newly created project' do
    login_as admin
    code_location = create(:code_location)
    create(:fetch_job, code_location: code_location, slave: create(:slave))
    project = create(:project)
    create(:enlistment, code_location: code_location, project: project)
    get admin_jobs_path, project_id: project.vanity_url
    assert_response :success
  end

  it 'should render project index page for analses completed project' do
    login_as admin
    project = create(:project)
    create(:fetch_job, project: project, slave: create(:slave))
    get admin_jobs_path, project_id: project.vanity_url
    assert_response :success
  end

  it 'should render jobs show page' do
    login_as admin
    job = create(:fetch_job, code_location: create(:code_location), slave: create(:slave))
    get admin_job_path(job)
    assert_response :success
  end

  it 'should allow to reschedule' do
    login_as admin
    job = create(:fetch_job, code_location: create(:code_location), slave: create(:slave))
    put reschedule_admin_job_path(job), {}, 'HTTP_REFERER' => admin_jobs_path
    assert_response :redirect
  end

  it 'should not allow to reschedule if job is running' do
    login_as admin
    job = create(:fetch_job, code_location: create(:code_location), slave: create(:slave), status: Job::STATUS_RUNNING)
    put reschedule_admin_job_path(job), {}, 'HTTP_REFERER' => admin_jobs_path
    assert_response :redirect
  end

  it 'should rebuild people' do
    login_as admin
    job = create(:fetch_job, code_location: create(:code_location), slave: create(:slave))
    put rebuild_people_admin_job_path(job), {}, 'HTTP_REFERER' => admin_jobs_path
    assert_response :redirect
  end

  it 'should index code_location jobs' do
    login_as admin
    get admin_code_location_jobs_path(create(:code_location))
    assert_response :success
  end

  it 'should update priority' do
    login_as admin
    job = create(:fetch_job, code_location: create(:code_location))
    put admin_job_path(job), job: { priority: 5 }
    assert_response :redirect
  end

  it 'should update retry_count' do
    login_as admin
    job = create(:fetch_job, code_location: create(:code_location))
    put admin_job_path(job), job: { retry_count: 3 }
    job.reload.retry_count.must_equal 3
  end

  it 'should delete job' do
    login_as admin
    job = create(:fetch_job, code_location: create(:code_location))
    assert_difference 'Job.count', -1 do
      delete admin_job_path(job)
    end
    assert_response :redirect
  end

  it 'should manually schedule job' do
    login_as admin
    post manually_schedule_admin_project_jobs_path(create(:project))
    assert_response :redirect
  end
end
