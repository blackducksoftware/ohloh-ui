require 'test_helper'

describe 'VulnerabilitiesControllerTest' do
  let(:project) { create(:project) }

  before do
    project.editor_account = create(:admin)
    project.update!(best_project_security_set_id: create(:project_security_set, project: project).id)
    pss_releases = create_list(:pss_release_vulnerability, 20, project_security_set: project.best_project_security_set,
                                                               vulnerability: nil)
    pss_releases.each do |pss|
      create(:pss_release_vulnerability, project_security_set: project.best_project_security_set, release: pss.release)
    end
  end

  describe 'version_chart' do
    it 'should return most ten recent releases data' do
      get :recent_version_chart, id: project.id, xhr: true
      assert_response :success
      assigns(:releases).must_equal(project.best_project_security_set.most_recent_releases)
    end

    it 'should return most ten recent releases vulnerabilities data' do
      get :recent_version_chart, id: project.id, xhr: true
      assert_response :success
      assigns(:releases).map { |r| r.vulnerabilities.flatten }
                        .must_equal(assigns(:best_project_security_set).most_recent_vulnerabilities)
    end
  end

  describe 'index' do
    it 'should return all release data from oldest to newest' do
      get :all_version_chart, id: project.id, xhr: true
      assert_response :success
      assigns(:releases).must_equal(project.best_project_security_set.releases.order(released_on: :asc))
    end
  end
end
