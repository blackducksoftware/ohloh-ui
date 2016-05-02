require 'test_helper'

describe 'Admin::JobsController'do
  let(:admin) { create(:admin) }
  let(:project) { create(:project, name: 'Testing', description: 'This is test project') }
  before { login_as admin }

  describe '#index' do
    it 'should render index template' do
      get :index, project_id: project.vanity_url
      must_respond_with :ok
      must_render_template :index
    end

    it 'should have action items' do
      get :index, project_id: project.vanity_url
      must_select "a[href='/admin/projects/#{project.vanity_url}/jobs/manually_schedule']", true
      must_select "a[href='/admin/projects/#{project.vanity_url}/jobs/analyze']", true
    end
  end

  describe '#analyze' do
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
end
