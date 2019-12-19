# frozen_string_literal: true

require 'test_helper'

class OrganizationAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'should render index page' do
    login_as admin

    create(:organization)
    get admin_organizations_path
    assert_response :success
  end

  it 'should render show page' do
    login_as admin
    organization = create(:organization)
    get admin_organization_path(organization)
    assert_response :success
  end
end
