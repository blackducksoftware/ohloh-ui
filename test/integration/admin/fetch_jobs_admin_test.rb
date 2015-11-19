require 'test_helper'

class FetchJobsAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: 'xyzzy123456') }
  let(:job) { create(:fetch_job, repository: create(:repository)) }

  it 'index loads' do
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_fetch_jobs_path
    assert_response :success
  end

  it 'loads show' do
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_job_path(job)
    assert_response :success
  end

  it 'destroy works' do
    admin.password = 'xyzzy123456'
    login_as admin
    delete admin_job_path(job)
    assert_response :redirect
  end
end
