require 'test_helper'

describe 'OhAdmin::JobsController' do
  let(:admin) { create(:admin) }
  let(:project) { create(:project, id: 1, name: 'Testing', description: 'This is test project') }

  it 'should render index template for a logged admin user' do
    login_as admin
    create(:slave, id: 1)
    VCR.use_cassette('project_jobs', match_requests_on: [:path]) do
      get :index, project_id: project.vanity_url, page: 1
      must_respond_with :success
    end
  end

  it 'should unauthorized for non admins' do
    get :index, project_id: project.vanity_url, page: 1
    must_respond_with :unauthorized
  end

  it 'should raise not found for invalid project' do
    login_as admin
    get :index, project_id: 'invalid_project', page: 1
    must_respond_with :not_found
  end
end
