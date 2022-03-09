# frozen_string_literal: true

require 'test_helper'

class OhAdmin::JobsControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }
  let(:project) { create(:project, id: 1, name: 'Testing', description: 'This is test project') }

  it 'should render index template for a logged admin user' do
    login_as admin
    create(:slave, id: 1)
    VCR.use_cassette('project_jobs', match_requests_on: [:path]) do
      get :index, params: { project_id: project.vanity_url, page: 1 }
      assert_response :success
    end
  end

  it 'should unauthorized for non admins' do
    get :index, params: { project_id: project.vanity_url, page: 1 }
    assert_response :unauthorized
  end

  it 'should raise not found for invalid project' do
    login_as admin
    get :index, params: { project_id: 'invalid_project', page: 1 }
    assert_response :not_found
  end

  it 'should render queued project jobs in jobs index page' do
    login_as admin
    create(:slave, id: 1)

    VCR.use_cassette('project_jobs', match_requests_on: [:path]) do
      get :index, params: { project_id: project.vanity_url }
    end

    _(assigns(:response)['entries'].collect { |j| j.values[0]['status'] }.uniq).must_include Job::STATUS_QUEUED
  end
end
