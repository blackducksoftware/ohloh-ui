# frozen_string_literal: true

require 'test_helper'

class OrganizationAnalysisJobAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'should render index page' do
    login_as admin
    create(:organization_analysis_job, organization: create(:organization))

    get admin_organization_analysis_jobs_path
    assert_response :success
  end

  it 'should render show page' do
    Job.any_instance.stubs(:code_location).returns(code_location_stub)
    login_as admin

    job = create(:organization_analysis_job)
    get admin_job_path(job)
    assert_response :success
  end
end
