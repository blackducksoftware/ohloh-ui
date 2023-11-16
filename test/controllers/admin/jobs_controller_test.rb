# frozen_string_literal: true

require 'test_helper'

class Admin::JobsControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }
  let(:project) { create(:project, name: 'Testing', description: 'This is test project') }
  before do
    Project.any_instance.stubs(:code_locations).returns([])
    login_as admin
  end

  it 'should render index template' do
    get :index, params: { project_id: project.vanity_url }
    assert_response :redirect
  end

  it 'should render index  with code_location template' do
    get :index, params: { code_location_id: 1 }
    assert_response :ok
  end
end
