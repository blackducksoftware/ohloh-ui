require 'test_helper'

class OrganizationAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: 'xyzzy123456') }

  it 'should render index page' do
    admin.password = 'xyzzy123456'
    login_as admin

    create(:organization)
    get admin_organizations_path
    assert_response :success
  end

  it 'should render show page' do
    admin.password = 'xyzzy123456'
    login_as admin
    organization = create(:organization)
    get admin_organization_path(organization)
    assert_response :success
  end
end
