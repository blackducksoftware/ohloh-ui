require 'test_helper'

describe 'VulnerabilitiesControllerTest' do
  describe 'version_chart' do
    it 'should return most ten recent releases data' do
      release = create(:release)
      create_list(:releases_vulnerability, 10, release: release)
      project = release.project_security_set.project
      get :version_chart, id: project.id, xhr: true
      assert_response :success
      assigns(:releases).must_equal(project.best_project_security_set.releases.last(1))
    end

    it 'should return most ten recent releases vulnerabilities data' do
      skip
      get :version_chart, id: project.id, xhr: true
      assert_response :success
      assigns(:releases).map { |r| r.vulnerabilities.flatten }
                        .must_equal(assigns(:best_project_security_set).most_recent_vulnerabilities)
    end
  end
end
