require 'test_helper'
require 'test_helpers/admin_test_helper'

class VulnerabilitiesAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }
  let(:pss_release_vulnerability) { create(:pss_release_vulnerability) }
  let(:vulnerability) { pss_release_vulnerability.vulnerability }
  let(:release) { pss_release_vulnerability.release }

  it 'should render index page' do
    login_as admin
    get admin_release_vulnerabilities_path(release)
    assert_response :success
  end

  it 'should render show page' do
    login_as admin
    get admin_release_vulnerability_path(release, vulnerability)
    assert_response :success
  end
end
