require 'test_helper'

class ProjectLicensesControllerTest < ActionController::TestCase
  # index
  it 'index should work for projects with no licenses' do
    project = create(:project)
    login_as nil
    get :index, project_id: project.to_param
    must_respond_with :ok
    must_select '#flash-msg .alert', 1
    must_select 'tr.license', 0
    must_select 'a.new-license', 1
    must_select 'a.new-license.needs_login', 1
    must_select 'a.new-license.disabled', 0
  end

  it 'index should work for projects with licenses' do
    project = create(:project)
    create(:project_license, project: project)
    create(:project_license, project: project)
    create(:project_license, project: project)
    login_as nil
    get :index, project_id: project.to_param
    must_respond_with :ok
    must_select '#flash-msg .alert', 0
    must_select 'tr.license', 3
    must_select 'a.new-license', 1
    must_select 'a.new-license.needs_login', 1
    must_select 'a.new-license.disabled', 0
  end

  it 'index should offer to allow adding licenses for logged in users' do
    project = create(:project)
    create(:project_license, project: project)
    create(:project_license, project: project)
    create(:project_license, project: project)
    login_as create(:account)
    get :index, project_id: project.to_param
    must_respond_with :ok
    must_select 'a.new-license', 1
    must_select 'a.new-license.needs_login', 0
    must_select 'a.new-license.disabled', 0
  end

  it 'index should not offer to allow adding licenses for non-managers' do
    project = create(:project)
    create(:project_license, project: project)
    create(:project_license, project: project)
    create(:project_license, project: project)
    create(:permission, target: project, remainder: true)
    login_as create(:account)
    get :index, project_id: project.to_param
    must_respond_with :ok
    must_select 'a.new-license', 1
    must_select 'a.new-license.needs_login', 0
    must_select 'a.new-license.disabled', 1
  end
end
