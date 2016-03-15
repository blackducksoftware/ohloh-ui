require 'test_helper'

class ProjectAdminTest < ActionDispatch::IntegrationTest
  let(:password) { SecureRandom.uuid }
  let(:admin) { create(:admin, password: password) }

  before do
    admin.password = password
    login_as admin
  end

  it 'should render index page' do
    create(:project)

    get admin_projects_path
    assert_response :success
  end

  it 'should render show page' do
    get admin_project_path(create(:project))
    assert_response :success
  end

  it 'must render the edit page' do
    get edit_admin_project_path(create(:project).to_param)
    assert_response :success
  end
end
