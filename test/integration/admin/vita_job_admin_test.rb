# frozen_string_literal: true

require 'test_helper'

class VitaJobAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'should render index page' do
    login_as admin
    create(:vita_job)
    get admin_vita_jobs_path
    assert_response :success
  end
end
