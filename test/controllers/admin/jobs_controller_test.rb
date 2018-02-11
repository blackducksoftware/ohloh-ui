require 'test_helper'

describe 'Admin::JobsController' do
  let(:admin) { create(:admin) }
  let(:project) { create(:project, name: 'Testing', description: 'This is test project') }
  before { login_as admin }

  it 'should render index template' do
    get :index, project_id: project.vanity_url
    must_respond_with :redirect
  end

  it 'should create a analysis job for the project' do
    assert_difference 'AnalyzeJob.count' do
      get :analyze, project_id: project.vanity_url
    end
  end

  it 'should redirect to index' do
    get :analyze, project_id: project.vanity_url
    must_redirect_to admin_project_jobs_path(project)
  end
end
