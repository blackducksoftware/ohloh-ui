# frozen_string_literal: true

require 'test_helper'

class AccountAnalysisJobAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'should render index page' do
    login_as admin
    create(:account_analysis_job)
    get admin_account_analysis_jobs_path
    assert_response :success
  end
end
