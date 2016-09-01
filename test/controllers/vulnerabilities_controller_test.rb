require 'test_helper'

class VulnerabilitiesControllerTest < ActionController::TestCase
  it 'should retrieve the 10 most recent releases for a project' do
    @project = create(:project)
    @project.project_security_sets << create(:project_security_set)
    @project.project_security_sets[0].releases << create_list(:release, 10)
    @project.project_security_sets[0].releases.each do |r|
      r.vulnerabilities << create(:vulnerability)
    end
    @project.update!(best_project_security_set_id: @project.project_security_sets[0].id, editor_account: create(:admin))
    get :index, project_id: @project.to_param
    assert_response :success
    assert_equal 10, Release.count
    assert_equal Release.order(released_on: :asc), assigns(:releases)
  end
end
