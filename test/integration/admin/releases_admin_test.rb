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

  it 'ransackable_associations delegates to authorizable_ransackable_associations' do
    expected = %w[vulnerabilities project_security_set]
    Release.expects(:authorizable_ransackable_associations).returns(expected)
    assert_equal expected, Release.ransackable_associations
  end

  it 'ransackable_associations passes auth_object parameter' do
    Release.expects(:authorizable_ransackable_associations).returns(['vulnerabilities'])
    assert_equal ['vulnerabilities'], Release.ransackable_associations('admin')
  end

  it 'ransackable_associations handles nil return' do
    Release.stubs(:authorizable_ransackable_associations).returns(nil)
    assert_nil Release.ransackable_associations
  end
end
