# frozen_string_literal: true

require 'test_helper'

class ProjectSbomsControllerTest < ActionController::TestCase
  before do
    @project = create(:project)
    @enlistments = create(:enlistment, project: @project, code_location_id: 1)
    @project_sboms = create(:project_sbom, project_id: @project.id, code_location_id: @enlistments.code_location_id)
  end

  describe 'index' do
    it 'should return project nil for invalid project id' do
      @controller = ProjectSbomsController.new
      get :index, params: { project_id: 'dummmyyyyyyyyyy' }
      _(assigns(:project)).must_be_nil
    end

    it 'should give success with valid project id' do
      get :index, params: { project_id: @project.vanity_url }, format: :js, xhr: true
      assert_response :ok
    end
  end
end
