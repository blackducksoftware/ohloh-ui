require 'test_helper'

class CompleteJobsAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: 'xyzzy123456') }
  let(:job) { create(:complete_job) }

  it 'index loads' do
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_complete_jobs_path
    assert_response :success
  end

  it 'should load project show page' do
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_job_path(job)
    assert_response :success
  end
end
