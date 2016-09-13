require 'test_helper'

describe 'VulnerabilitiesControllerTest' do
  let(:project) { create(:project) }

  before do
    project.editor_account = create(:admin)
    project.update!(best_project_security_set_id: create(:project_security_set, project: project).id)
    project.best_project_security_set.releases << create_list(:release, 20, project_security_set: nil)
    project.best_project_security_set.releases.each do |r|
      r.vulnerabilities << create(:vulnerability, release: nil)
    end
  end

  describe 'version_chart' do
    it 'should return most recent releases data' do
      get :version_chart, id: project.id, xhr: true
      assert_response :success
      assigns(:releases).must_equal(project.best_project_security_set.releases.last(10))
    end
  end

  describe 'index' do
    it 'should return all release data from oldest to newest' do
      get :index, project_id: project.id, xhr: true
      assert_response :success
      assigns(:releases).must_equal(project.best_project_security_set.releases.order(released_on: :asc))
    end
  end
end
