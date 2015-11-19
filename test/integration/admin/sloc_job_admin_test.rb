require 'test_helper'

class SlocJobsAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: 'xyzzy123456') }
  let(:job) { create(:sloc_job, repository: create(:repository, best_code_set: create(:code_set))) }

  it 'index loads' do
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_sloc_jobs_path
    assert_response :success
  end

  it 'loads show' do
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_job_path(job)
    assert_response :success
  end
end
