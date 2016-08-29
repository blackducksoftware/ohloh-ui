require 'test_helper'
require 'test_helpers/admin_test_helper'

class ProjectSecuritySetAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'should render index page' do
    login_as admin
    get admin_project_security_sets_path
    assert_response :success
  end

  it 'should render show page' do
    login_as admin
    get admin_project_security_set_path(create(:project_security_set))
    assert_response :success
  end
end
