# frozen_string_literal: true

require 'test_helper'

class ProjectSbomsControllerTest < ActionController::TestCase
  before do
    @project = create(:project)
    @enlistments = create(:enlistment, project: @project, code_location_id: 1)
    @project_sboms = create(:project_sbom, agent: 'syft', project_id: @project.id,
                                           code_location_id: @enlistments.code_location_id,
                                           sbom_data: { SPDXID: 'SPDXRef-DOCUMENT' }.to_json)
  end

  describe 'index' do
    it 'should return project nil for invalid project id' do
      @controller = ProjectSbomsController.new
      get :index, params: { project_id: Faker::Number.number(digits: 3) }
      _(assigns(:project)).must_be_nil
    end

    it 'should give success with valid project id' do
      get :index, params: { project_id: @project.vanity_url }, format: :js, xhr: true
      assert_response :ok
    end

    it 'should give success with valid package details dependency' do
      sbom_data = { reportContent: [{ fileContent: { packages: [{ externalRefs: [{ referenceCategory: 'PACKAGE',
                                                                                   referenceLocator: 'pkg:maven/org.b',
                                                                                   referenceType: 'purl' }] }] } }] }
      @project_sboms = create(:project_sbom, agent: 'detect_wizard', project_id: @project.id,
                                             code_location_id: @enlistments.code_location_id,
                                             sbom_data: sbom_data)
      get :index, params: { project_id: @project.vanity_url }, format: :js, xhr: true
      assert_response :ok
    end
  end

  describe 'download data file' do
    it 'should give success with valid project id' do
      get :download_json, params: { project_id: @project.vanity_url, agent: 'syft' }
      assert_response :ok
    end
  end
end
