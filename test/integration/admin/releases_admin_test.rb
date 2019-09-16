# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/admin_test_helper'

class ReleaseAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }
  let(:release) { create(:release) }
  let(:project_security_set) { release.project_security_set }

  it 'should render index page' do
    login_as admin
    get admin_project_security_set_releases_path(project_security_set)
    assert_response :success
  end

  it 'should render show page' do
    login_as admin
    get admin_project_security_set_release_path(project_security_set, release)
    assert_response :success
  end
end
