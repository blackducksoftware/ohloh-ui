require 'test_helper'

describe 'Admin::JobsController' do
  let(:admin) { create(:admin) }
  let(:project) { create(:project, name: 'Testing', description: 'This is test project') }
  before { login_as admin }

  it 'should render index template' do
    get :index, project_id: project.vanity_url
    must_respond_with :redirect
  end
end
