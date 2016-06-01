require 'test_helper'

class FetchJobsAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }
  let(:job) { create(:fetch_job, code_location: create(:code_location)) }

  it 'index loads' do
    login_as admin
    get admin_fetch_jobs_path
    assert_response :success
  end

  it 'loads show' do
    login_as admin
    get admin_job_path(job)
    assert_response :success
  end

  it 'destroy works' do
    login_as admin
    delete admin_job_path(job)
    assert_response :redirect
  end
end
