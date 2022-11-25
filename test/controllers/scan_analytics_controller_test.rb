# frozen_string_literal: true

require 'test_helper'

class ScanAnalyticsControllerTest < ActionController::TestCase
  let(:project) { create(:project) }
  let(:enlistment) { create_enlistment_with_code_location(project) }
  let(:code_set) { create(:code_set, code_location_id: enlistment.code_location_id) }
  let(:analysis) { create(:analysis, min_month: Date.current - 5.months) }
  let(:analytics_data) do
    { project: 'Ohloh_SCM', project_id: 1, loc: 10, project_url: 'https://scan.coverity.com/projects/ohloh_scm',
      analysis_metrics: { version: '1', build_date: '2022-10-27', loc: 10, components_loc: 'N/A',
                          defect_density: { score: 0.04, over_time: [{ '2022-10-19': 0.04, '2022-10-27': 0.04 }] },
                          prev_build_date: '2022-10-19', new_count: 0, eliminated_count: 0, total_count: 2,
                          outstanding_count: 2, dismissed_count: 0, fixed_count: 0 },
      cwe: [{ id: 6, rank: 8, uri: 'http://cwe.mitre.org/top25/#CWE-676',
              name: 'Use of Potentially Dangerous Function', defect_count: 1 }] }
  end

  let(:charts_data) do
    { fixed_defects: { 'Oct 13, 2022': 0 },
      outstanding_defects: { 'Oct 13, 2022': 35 },
      defect_density: [{ name: 'Defect Density of Ohloh_SCM',
                         data: { 'Oct 13, 2022': '0.04' } }] }
  end

  before do
    Project.any_instance.stubs(:code_locations).returns([CodeLocation.new(id: enlistment.code_location_id)])
    project.update_column(:best_analysis_id, analysis.id)
  end

  describe '#index' do
    before do
      create(:scan_analytic, analysis_id: analysis.id, code_set_id: code_set.id, data: analytics_data.to_json,
                             data_type: 'Analytics')
    end

    it 'must return valid scan analytics data' do
      get :index, params: { project_id: project.to_param }
      expect(assigns(:analytics)).wont_be_empty
      expect(assigns(:scan_data)).wont_be_nil
      assert_response :ok
    end

    it 'must return empty if data not found for provided code set' do
      get :index, params: { project_id: project.to_param, code_set_id: create(:code_set) }
      expect(assigns(:analytics)).wont_be_empty
      expect(assigns(:scan_data)).must_be_nil
      assert_response :ok
    end

    it 'must return nil if scan analytics data not found' do
      get :index, params: { project_id: create(:project).id }
      expect(assigns(:analytics)).must_be_empty
      expect(assigns(:scan_data)).must_be_nil
      assert_response :ok
    end

    it 'must return nil if best analysis not found' do
      project.update_column(:best_analysis_id, nil)
      get :index, params: { project_id: project.id }
      expect(assigns(:analytics)).must_be_nil
      expect(assigns(:scan_data)).must_be_nil
      assert_response :ok
    end
  end

  describe '#charts' do
    before do
      create(:scan_analytic, analysis_id: analysis.id, code_set_id: code_set.id, data: charts_data.to_json,
                             data_type: 'Charts')
    end

    it 'must return valid charts data' do
      get :charts, params: { project_id: project.to_param, code_set_id: code_set.id }, format: :json
      expect(response.body).wont_be_empty
      assert_equal response.body, charts_data.to_json
      assert_response :success
    end

    it 'must return empty if data not found for provided code set' do
      get :charts, params: { project_id: project.to_param, code_set_id: create(:code_set) }, format: :json
      assert_equal response.body, '{}'
      assert_response :success
    end

    it 'must return not found if scan analytics data not found' do
      get :charts, params: { project_id: create(:project).id }, format: :json
      assert_response :bad_request
    end

    it 'must return not found if best analysis not found' do
      project.update_column(:best_analysis_id, nil)
      get :charts, params: { project_id: project.id }, format: :json
      assert_response :bad_request
    end
  end
end
