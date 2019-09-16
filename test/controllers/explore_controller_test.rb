# frozen_string_literal: true

require 'test_helper'

describe 'ExploreController' do
  describe 'explore orgs' do
    (1..5).to_a.each do |value|
      let("org#{value}") { create(:organization, name: "org_#{value}", vanity_url: "org#{value}") }
      let("ota#{value}") do
        create(:org_thirty_day_activity, name: "org_#{value}", vanity_url: "org#{value}",
                                         organization: send("org#{value}"), affiliate_count: 20,
                                         thirty_day_commit_count: 200 * value)
      end
    end

    before do
      @stat1 = create(:org_stats_by_sector)
      @stat2 = create(:org_stats_by_sector, org_type: 2, organization_count: 20)
      @stat3 = create(:org_stats_by_sector, org_type: 3, organization_count: 40)
      @stat4 = create(:org_stats_by_sector, org_type: 4, organization_count: 50)

      (1..5).to_a.each do |value|
        ota = send("ota#{value}")
        send("org#{value}").update_column(:thirty_day_activity_id, ota.id)
      end
    end

    describe 'orgs' do
      it 'should respond with the necessary data when filter is all' do
        get :orgs

        must_respond_with :ok
        assigns(:newest_orgs).must_equal [org5, org4, org3]
        assigns(:most_active_orgs).map(&:name).must_equal [ota5.name, ota4.name, ota3.name]
        assigns(:stats_by_sector).must_equal [@stat4, @stat3, @stat2, @stat1]
        assigns(:org_by_30_day_commits).must_equal [ota5, ota4, ota3, ota2, ota1]
      end
    end

    describe 'orgs_by_thirty_day_commit_volume' do
      it 'should return json of filtered record when filter is all_orgs' do
        xhr :get, :orgs_by_thirty_day_commit_volume, format: :js, filter: 'all_orgs'

        must_respond_with :ok
        assigns(:org_by_30_day_commits).must_equal [ota5, ota4, ota3, ota2, ota1]
      end

      it 'should return json of filtered record when filter is government' do
        OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(org_type: 3)
        xhr :get, :orgs_by_thirty_day_commit_volume, filter: 'government', format: 'js'

        must_respond_with :ok
        assigns(:org_by_30_day_commits).must_equal [ota5, ota4, ota3]
      end

      it 'should return json of filtered record when filter is all' do
        xhr :get, :orgs_by_thirty_day_commit_volume, filter: 'all_orgs', format: :js

        must_respond_with :ok
        assigns(:org_by_30_day_commits).must_equal [ota5, ota4, ota3, ota2, ota1]
      end

      it 'should return json of filtered record when filter is none' do
        xhr :get, :orgs_by_thirty_day_commit_volume, format: :js, filter: ''

        must_respond_with :ok
        assigns(:org_by_30_day_commits).must_equal [ota5, ota4, ota3, ota2, ota1]
      end
    end
  end

  describe 'explore projects' do
    let(:logo_1) { create(:logo) }
    let(:logo_2) { create(:logo) }
    let(:lang_1) { create(:language, nice_name: 'testa') }
    let(:lang_2) { create(:language, nice_name: 'testb') }
    let(:project_1) { create(:project, name: 'testa', logo_id: logo_1.id, activity_level_index: 20) }
    let(:project_2) { create(:project, name: 'testb', logo_id: logo_2.id, activity_level_index: 40) }

    before do
      Project.update_all(activity_level_index: nil)
      Analysis.update_all(hotness_score: nil)
      project_1.best_analysis.update_columns(hotness_score: 70, main_language_id: lang_1.id)
      project_2.best_analysis.update_columns(hotness_score: 60, main_language_id: lang_2.id)
    end

    describe 'projects' do
      it 'should return all projects related data' do
        get :projects

        must_respond_with :ok
        assigns(:projects).must_equal [project_1, project_2]
        assigns(:project_logos_map)[logo_1.id].must_equal logo_1
        assigns(:project_logos_map)[logo_2.id].must_equal logo_2
        assigns(:with_pai_count).must_equal 2
        assigns(:total_count).must_equal Project.active.count
        assigns(:languages).must_include ['All Languages', '']
        assigns(:languages).must_include [lang_1.nice_name, lang_1.name]
        assigns(:languages).must_include [lang_2.nice_name, lang_2.name]
      end
    end

    describe 'index' do
      it 'should return all projects related data' do
        get :index

        must_respond_with :ok
        must_render_template :projects

        assigns(:projects).map(&:id).sort.must_equal [project_1.id, project_2.id].sort
        assigns(:project_logos_map)[logo_1.id].must_equal logo_1
        assigns(:project_logos_map)[logo_2.id].must_equal logo_2
        assigns(:with_pai_count).must_equal 2
        assigns(:total_count).must_equal Project.active.count
        assigns(:languages).must_include ['All Languages', '']
        assigns(:languages).must_include [lang_1.nice_name, lang_1.name]
        assigns(:languages).must_include [lang_2.nice_name, lang_2.name]
      end

      it 'should render projects explore page with language param' do
        get :index, lang: lang_1.name
        must_respond_with :ok
        must_render_template :projects
      end
    end

    describe 'demographic_chart' do
      it 'should return chart json data' do
        get :demographic_chart

        result = JSON.parse(@response.body)
        data = result['series'].last['data'].first

        must_respond_with :ok
        result['chart']['type'].must_equal 'pie'
        data['name'].must_equal 'Inactive'
        data['color'].must_equal '#2369C8'
        data['y'].must_equal 50.0
        data['sliced'].must_equal true
        data['selected'].must_equal true
      end
    end
  end
end
