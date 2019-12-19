# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/admin_test_helper'

class VulnerabilitiesAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }
  let(:release) { create(:release) }
  let(:project_security_set) { release.project_security_set }
  let(:create_vulnerability) { create(:vulnerability, releases: [release]) }

  it 'should render index page' do
    login_as admin
    create_vulnerability
    get admin_release_vulnerabilities_path(release)
    assert_response :success
  end

  it 'should render show page' do
    login_as admin
    get admin_release_vulnerability_path(release, create_vulnerability)
    assert_response :success
  end
end
