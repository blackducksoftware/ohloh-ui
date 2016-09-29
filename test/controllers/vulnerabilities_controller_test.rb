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
                        .must_equal(assigns(:best_security_set).most_recent_vulnerabilities)
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
      assigns(:releases).must_equal(project.best_project_security_set.releases)
    end

    it 'should not show the project security table when no vulnerability reported' do
      get :index, id: create(:project).to_param
      assigns(:vulnerabilities).must_equal nil
      response.body.must_match I18n.t('vulnerabilities.index.no_vulnerability')
    end

    it 'should show project security table' do
      release = create(:release)
      create_list(:releases_vulnerability, 10, release: release)
      get :index, id: release.project_security_set.project.to_param
      assigns(:vulnerabilities).count.must_equal 10
    end
  end

  describe 'Security data filtering' do
    let(:security_set) { create(:project_security_set) }
    let(:r1_0) { create(:release, version: '1.0', released_on: 11.years.ago, project_security_set: security_set) }
    let(:r1_1) { create(:release, version: '1.1', released_on: 8.years.ago, project_security_set: security_set) }
    let(:r1_2) { create(:release, version: '1.2', released_on: 3.years.ago, project_security_set: security_set) }
    let(:r1_3) { create(:release, version: '1.3', released_on: 8.months.ago, project_security_set: security_set) }
    let(:r2_2) { create(:release, version: '2.2', released_on: 5.months.ago, project_security_set: security_set) }
    let(:r3_3) { create(:release, version: '3.3', released_on: 1.month.ago, project_security_set: security_set) }

    before do
      [r1_0, r1_1, r1_2, r1_3, r2_2, r3_3].each do |r|
        3.times do |s|
          create(:releases_vulnerability, release: r, vulnerability: create(:vulnerability, severity: s))
        end
      end
    end

    describe 'index' do
      it 'should return all vulnerabilities of the most recent version for default filtering' do
        get :index, id: security_set.project.to_param
        must_render_template :index
        must_render_template 'vulnerabilities/_version_filter'
        assigns(:latest_version).must_equal r3_3
        assigns(:minor_versions).to_a.must_equal [r3_3, r2_2, r1_3, r1_2, r1_1, r1_0]
        assigns(:vulnerabilities).to_a.must_equal r3_3.vulnerabilities.sort_by_cve_id
      end

      it 'should return the vulnerabilities of the most recent minor version within the chosen major version' do
        get :index, id: security_set.project.to_param, filter: { major_version: '1' }
        assigns(:latest_version).must_equal r1_3
        assigns(:minor_versions).to_a.must_equal [r1_3, r1_2, r1_1, r1_0]
        assigns(:vulnerabilities).to_a.must_equal r1_3.vulnerabilities.sort_by_cve_id
      end

      it 'should return the vulnerabilities of the most recent minor version within the chosen time span' do
        get :index, id: security_set.project.to_param, filter: { major_version: '1', period: '1' }
        assigns(:latest_version).must_equal r1_3
        assigns(:minor_versions).to_a.must_equal [r1_3]
        assigns(:vulnerabilities).to_a.must_equal r1_3.vulnerabilities.sort_by_cve_id
      end
    end

    describe 'filter' do
      it 'should return the vulnerabilities of the chosen version' do
        get :filter, id: security_set.project.to_param,
                     filter: { major_version: '1', version: r1_2.id, period: '5' }, xhr: true
        must_render_template 'vulnerabilities/_vulnerability_table'
        must_render_template 'vulnerabilities/_version_filter'
        assigns(:latest_version).must_equal r1_2
        assigns(:minor_versions).to_a.must_equal [r1_3, r1_2]
        assigns(:vulnerabilities).to_a.must_equal r1_2.vulnerabilities.sort_by_cve_id
      end

      it 'should return the vulnerabilities of the chosen severity' do
        get :filter, id: security_set.project.to_param,
                     filter: { major_version: '1', severity: 'medium' }, xhr: true
        assigns(:latest_version).must_equal r1_3
        assigns(:vulnerabilities).count.must_equal 1
        assigns(:vulnerabilities).to_a.must_equal r1_3.vulnerabilities.medium.sort_by_cve_id
      end

      it 'should return the vulnerabilities of all severity types when severity param is blank' do
        get :filter, id: security_set.project.to_param,
                     filter: { major_version: '1', severity: '' }, xhr: true
        assigns(:latest_version).must_equal r1_3
        assigns(:vulnerabilities).count.must_equal 3
        assigns(:vulnerabilities).to_a.must_equal r1_3.vulnerabilities.sort_by_cve_id
      end
    end
  end
end
