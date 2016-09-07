require 'test_helper'
require 'test_helpers/admin_test_helper'

class ReleaseAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }
  let(:pss_release_vulnerability) { create(:pss_release_vulnerability) }
  let(:release) { pss_release_vulnerability.release }

  it 'should render index page' do
    login_as admin
    get admin_project_security_set_releases_path(pss_release_vulnerability.project_security_set)
    assert_response :success
  end

  it 'should render show page' do
    login_as admin
    pss = pss_release_vulnerability.project_security_set
    get admin_project_security_set_release_path(pss, release)
    assert_response :success
  end
end
