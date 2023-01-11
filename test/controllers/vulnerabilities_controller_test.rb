# frozen_string_literal: true

require 'test_helper'

class VulnerabilitiesControllerTest < ActionController::TestCase
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
      get :recent_version_chart, params: { id: project.id }, xhr: true
      assert_response :success
      _(assigns(:releases).map { |r| r.vulnerabilities.to_a.flatten })
        .must_equal(assigns(:best_security_set)
                          .most_recent_releases.map { |r| r.vulnerabilities.to_a.flatten })
    end

    it 'should return most ten recent releases data' do
      get :recent_version_chart, params: { id: project.id }, xhr: true
      assert_response :success
      _(assigns(:releases)).must_equal(project.best_project_security_set.most_recent_releases)
      _(response.body).wont_match 'BDSA'
    end

    it 'should return BDSA data for admin' do
      login_as create(:admin)
      get :recent_version_chart, params: { id: project.id }, xhr: true
      assert_response :success
      _(response.body).must_match 'BDSA'
    end
  end

  describe 'index' do
    it 'the index page should have all release data from oldest to newest' do
      get :index, params: { id: project.id }
      assert_response :success
      _(assigns(:releases)).must_equal(project.best_project_security_set.releases)
    end

    it 'should not show the project security table when no vulnerability reported' do
      get :index, params: { id: create(:project).to_param }
      _(assigns(:vulnerabilities)).must_be_nil
      _(response.body).must_match I18n.t('vulnerabilities.index.no_vulnerability')
    end

    it 'should show project security table' do
      release = create(:release)
      create_list(:releases_vulnerability, 10, release: release)
      get :index, params: { id: release.project_security_set.project.to_param }
      _(assigns(:vulnerabilities).length).must_equal 10
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
      it 'should return all vulnerabilities of the matching most recent version for default filtering' do
        get :index, params: { id: security_set.project.to_param }
        assert_template :index
        assert_template 'vulnerabilities/_version_filter'
        _(assigns(:release)).must_equal r3_3
        _(assigns(:minor_versions).to_a).must_equal [r3_3, r2_2, r1_3]
        _(assigns(:vulnerabilities).to_a).must_equal r3_3.vulnerabilities.order_by
      end

      it 'should return the vulnerabilities of the most recent minor version within the chosen major version' do
        get :index, params: { id: security_set.project.to_param, filter: { major_version: '1' } }
        _(assigns(:release)).must_equal r1_3
        _(assigns(:minor_versions).to_a).must_equal [r1_3]
        _(assigns(:vulnerabilities).to_a).must_equal r1_3.vulnerabilities.order_by
      end

      it 'should return the vulnerabilities of the most recent minor version within the chosen time span' do
        get :index, params: { id: security_set.project.to_param, filter: { major_version: '1', period: '1' } }
        _(assigns(:release)).must_equal r1_3
        _(assigns(:minor_versions).to_a).must_equal [r1_3]
        _(assigns(:vulnerabilities).to_a).must_equal r1_3.vulnerabilities.order_by
      end

      it 'Release timespan should be disable if there are no releases availble within the timespan' do
        security_set = create(:project_security_set)
        create(:release, version: '1.0', released_on: 5.years.ago, project_security_set: security_set)
        get :index, params: { id: security_set.project.to_param }
        _(response.body).must_match '<div class="btn btn-info btn-mini release_timespan disabled" date="1">1yr</div>'
        _(response.body).must_match '<div class="btn btn-info btn-mini release_timespan disabled" date="3">3yr</div>'
      end

      describe 'Default timespan' do
        describe 'when oldest vulnerability is reported 5 years ago or more' do
          it 'should return vulnerabilities of the releases available within 3 years' do
            r1_3.vulnerabilities.first.update published_on: 6.years.ago
            get :index, params: { id: security_set.project.to_param }
            _(assigns(:minor_versions).to_a).must_equal [r3_3, r2_2, r1_3, r1_2]
          end
        end

        describe 'when oldest vulnerability is reported 5 years below' do
          it 'should return vulnerabilities of the releases available within 1 year' do
            r2_2.vulnerabilities.first.update published_on: 4.years.ago
            get :index, params: { id: security_set.project.to_param }
            _(assigns(:minor_versions).to_a).must_equal [r3_3, r2_2, r1_3]
          end
        end
      end
    end

    describe 'filter' do
      it 'should return the vulnerabilities of the chosen version' do
        get :filter, params: { id: security_set.project.to_param,
                               filter: { version: r1_3.id } }, xhr: true
        assert_template 'vulnerabilities/_vulnerability_table'
        _(assigns(:vulnerabilities).to_a).must_equal r1_3.vulnerabilities.order_by
      end

      it 'should return the vulnerabilities of the chosen severity' do
        get :filter, params: { id: security_set.project.to_param,
                               filter: { version: r1_3.id, severity: 'medium' } }, xhr: true
        _(assigns(:vulnerabilities).length).must_equal 1
        _(assigns(:vulnerabilities).to_a).must_equal r1_3.vulnerabilities.medium.order_by
      end

      it 'should return the vulnerabilities of all severity types when severity param is blank' do
        get :filter, params: { id: security_set.project.to_param,
                               filter: { version: r1_3.id, severity: '' } }, xhr: true
        _(assigns(:vulnerabilities).length).must_equal 3
        _(assigns(:vulnerabilities).to_a).must_equal r1_3.vulnerabilities.order_by
      end
    end
  end
end
