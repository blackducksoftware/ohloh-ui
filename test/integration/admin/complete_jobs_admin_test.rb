require 'test_helper'

class CompleteJobsAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }
  let(:job) { create(:complete_job) }

  it 'index loads' do
    login_as admin
    get admin_complete_jobs_path
    assert_response :success
  end

  it 'should load project show page' do
    Job.any_instance.stubs(:code_location).returns(code_location_stub)
    login_as admin
    get admin_job_path(job)
    assert_response :success
  end
end
