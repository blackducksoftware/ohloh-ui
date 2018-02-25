require 'test_helper'

describe 'Admin::JobsController' do
  let(:admin) { create(:admin) }
  let(:project) { create(:project, name: 'Testing', description: 'This is test project') }
  before do
    Project.any_instance.stubs(:code_locations).returns([])
    login_as admin
  end

  it 'should render index template' do
    get :index, project_id: project.vanity_url
    must_respond_with :redirect
  end
end
