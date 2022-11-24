# frozen_string_literal: true

require 'test_helper'

class ScanAnalyticsControllerTest < ActionController::TestCase
  before do
    Project.any_instance.stubs(:code_locations).returns([])
    Enlistment.any_instance.stubs(:code_location).returns(code_location_stub)
    @project = create(:project)
    enlistment = create_enlistment_with_code_location
    code_set = create(:code_set, code_location_id: enlistment.code_location_id)
    code_location = CodeLocation.new(id: enlistment.code_location_id, url: 'url')
    Project.any_instance.stubs(:code_locations).returns([code_location])
    CodeSet.any_instance.stubs(:code_location).returns(code_location)
    @analysis = create(:analysis, min_month: Date.current - 5.months)
    @project.update_column(:best_analysis_id, @analysis.id)
    data = { 'cwe' => [{ 'id' => 676, 'uri' => 'http://cwe.mitre.org/top25/#CWE-676',
                         'name' => 'Use of Potential', 'rank' => 1, 'defect_count' => 1 }],
             'loc' => 83_976, 'project' => 'Ohloh_SCM', 'project_url' => 'https://scan.coverity.com/projects/ohloh_scm',
             'analysis_metrics' => { 'loc' => 83_976, 'version' => 'bc9296d72aa6bb',
                                     'new_count' => 0, 'build_date' => '2022-10-13', 'fixed_count' => 0,
                                     'total_count' => 35, 'components_loc' => 'N/A',
                                     'defect_density' => { 'score' => 0.04, 'over_time' => [{ '2022-1-1' => 0 }] },
                                     'dismissed_count' => 0, 'outstanding_count' => 35 } }
    @scan_analytics = create(:scan_analytic, analysis_id: @analysis.id, code_set_id: code_set.id, data: data.to_json)
  end

  it 'must return valid scan analytics data' do
    get :index, params: { project_id: @project.to_param }

    assert_response :ok
  end

  it 'must return valid charts data' do
    VCR.use_cassette('scan_project_url') do
      get :charts, params: { project_id: @project.to_param, scan_id: 1 }, format: :json

      assert_response :success
    end
  end
end
