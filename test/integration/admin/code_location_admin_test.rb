require 'test_helper'

class CodeLocationAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'should render index page' do
    login_as admin
    create(:code_location)
    get admin_code_locations_path
    assert_response :success
  end

  it 'should render show page' do
    login_as admin
    get admin_code_location_path(create(:code_location))
    assert_response :success
  end

  it 'should refetch the code_location' do
    login_as admin
    get refetch_admin_code_location_path(create(:code_location))
    assert_response :redirect
  end
end
