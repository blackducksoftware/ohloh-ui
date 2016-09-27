require 'test_helper'

describe 'VulnerabilitiesControllerTest' do
  let(:project) { create(:project) }

  before do
    project.editor_account = create(:admin)
    project.update!(best_project_security_set_id: create(:project_security_set, project: project).id)
    pss_releases = project.best_project_security_set.releases << create_list(:release, 20)
    pss_releases.each do |r|
      r.vulnerabilities << create(:vulnerability)
    end
  end

  describe 'recent version_chart' do
    it 'should return most ten recent releases vulnerabilities data' do
      get :recent_version_chart, id: project.id, xhr: true
      assert_response :success
      assigns(:releases).map { |r| r.vulnerabilities.flatten }
                        .must_equal(assigns(:best_project_security_set).most_recent_vulnerabilities)
    end

    it 'should return most ten recent releases data' do
      get :recent_version_chart, id: project.id, xhr: true
      assert_response :success
      assigns(:releases).must_equal(project.best_project_security_set.most_recent_releases)
    end
  end

  describe 'all_version_chart' do
    it 'should return all release data from oldest to newest' do
      get :all_version_chart, id: project.id, xhr: true
      assert_response :success
      assigns(:releases).must_equal(project.best_project_security_set.releases.order(released_on: :asc))
    end
  end

  describe 'index' do
    it 'the index page should have all release data from oldest to newest' do
      get :index, id: project.id
      assert_response :success
      assigns(:releases).must_equal(project.best_project_security_set.all_releases)
    end
  end
end
