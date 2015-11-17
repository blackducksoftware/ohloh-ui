require 'test_helper'

class ProjectTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: 'xyzzy123456') }

  it 'should render index page' do
    admin.password = 'xyzzy123456'
    login_as admin
    create(:project)

    get admin_projects_path
    assert_response :success
  end

  it 'should render show page' do
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_project_path(create(:project))
    assert_response :success
  end
end
