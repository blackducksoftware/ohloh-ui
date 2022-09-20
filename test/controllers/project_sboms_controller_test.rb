# frozen_string_literal: true

require 'test_helper'

class ProjectSbomsControllerTest < ActionController::TestCase
  before do
    @project = create(:project)
    @enlistments = create(:enlistment, project: @project, code_location_id: 1)
    @project_sboms = create(:project_sbom, project_id: @project.id, code_location_id: @enlistments.code_location_id)
  end

  describe 'index' do
    it 'should not show permission alert' do
      get :index, params: { project_id: @project.id }
      _(flash.count).must_equal 0
    end

    it 'should not return project sboms if invalid project id' do
      get :index, params: { project_id: 'dummy data' }
      _(assigns(:project_sbom)).must_be_nil
    end

    it 'should return project nil for invalid project id' do
      @controller = ProjectSbomsController.new
      get :index, params: { project_id: 'dummmyyyyyyyyyy' }
      @controller.instance_eval { find_project }
      _(assigns(:project)).must_be_nil
    end
  end
end
