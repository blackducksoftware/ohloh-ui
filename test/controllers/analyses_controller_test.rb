# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/xml_parsing_helpers'

class AnalysesControllerTest < ActionController::TestCase
  let(:beginning_of_month) { Time.current.beginning_of_month }
  let(:second_day_of_month) { beginning_of_month.advance(days: 1) }
  let(:account) { create(:account) }
  let(:activity_fact) { create(:activity_fact, code_added: 5, code_removed: 3, blanks_added: 3, blanks_removed: 0) }
  let(:activity_fact_2) do
    options = { analysis: activity_fact.analysis, code_added: 6, code_removed: 5, blanks_added: 5, blanks_removed: 4,
                month: second_day_of_month }
    create(:activity_fact, options)
  end
  let(:analysis) do
    activity_fact_2.analysis.update!(updated_on: Date.current, oldest_code_set_time: Date.current)
    activity_fact_2.analysis
  end
  let(:project) { analysis.project }
  let(:api_key) { create(:api_key, account_id: account.id, daily_limit: 100) }
  let(:date_range) { [3.months.ago, 2.months.ago, 1.month.ago, Date.current].map(&:beginning_of_month) }
  let(:create_all_months) do
    AllMonth.delete_all
    date_range.each { |date| create(:all_month, month: date) }
  end
  let(:time_integer) { AllMonth.all.to_a.last.month.utc.to_i * 1000 }

  describe 'show' do
    it 'should redirect to project page for html request' do
      get :show, params: { project_id: project.to_param, id: analysis.id }
      assert_redirected_to project_path(project)
    end

    it 'should respond with 400 if api_key is wrong' do
      get :show, params: { project_id: project.to_param, id: analysis.id, format: :xml, api_key: 'badkey' }
      assert_response :bad_request
    end

    it 'must respond with valid data for xml request' do
      url = "http://test.host/p/#{project.vanity_url}/analyses/#{analysis.id}"
      client_id = api_key.oauth_application.uid

      get :show, params: { project_id: project.to_param, id: analysis.id, format: :xml, api_key: client_id }

      result = xml_hash(@response.body)['response']
      analysis_result = result['result']['analysis']

      assert_response :ok
      _(result['status']).must_equal 'success'
      _(analysis_result['id']).must_equal analysis.id.to_s
      _(analysis_result['url']).must_equal "#{url}.xml"
      _(analysis_result['project_id']).must_equal project.id.to_s
      _(analysis_result['updated_at']).must_equal xml_time(Date.current)
      _(analysis_result['min_month']).must_equal((Date.current - 1.month).to_s)
      _(analysis_result['max_month']).must_equal((Date.current - 1.day).to_s)
      _(analysis_result['twelve_month_contributor_count']).must_be_nil
      _(analysis_result['total_contributor_count']).must_be_nil
      _(analysis_result['twelve_month_commit_count']).must_equal '4'
      _(analysis_result['total_commit_count']).must_be_nil
      _(analysis_result['total_code_lines']).must_equal '303'
      _(analysis_result['languages']['graph_url']).must_equal "#{url}/languages.png"
      _(analysis_result['main_language_id']).must_equal analysis.main_language.id.to_s
      _(analysis_result['main_language_name']).must_equal analysis.main_language.nice_name
    end

    it 'must render projects/deleted when project is deleted' do
      login_as account
      project.update!(deleted: true, editor_account: account)

      get :show, params: { project_id: project.to_param, id: analysis.id }

      assert_template 'deleted'
    end
  end

  describe 'languages_summary' do
    it 'should set the language_breakdown data' do
      activity_fact_2.update!(language: activity_fact.language)
      get :languages_summary, params: { project_id: project.to_param, id: analysis.id }

      assert_response :ok
      _(assigns(:analysis)).must_equal analysis
      _(assigns(:project)).must_equal project
      _(assigns(:languages_breakdown).first.code_total).must_equal 3
      _(assigns(:languages_breakdown).first.blanks_total).must_equal 4
    end

    it 'must render the page correctly when no analysis' do
      Project.any_instance.stubs(:best_analysis).returns(NilAnalysis.new)
      get :languages_summary, params: { project_id: project.to_param, id: 999 }

      assert_response :ok
    end
  end

  describe 'top_commit_volume_chart' do
    it 'should return chart data json' do
      name_fact = create(:name_fact, thirty_day_commits: 5, twelve_month_commits: 8, commits: 50)
      analysis = name_fact.analysis
      get :top_commit_volume_chart, params: { project_id: project.to_param, id: analysis.id }

      result = JSON.parse(@response.body)['series']

      assert_response :ok
      _(assigns(:analysis)).must_equal analysis
      _(assigns(:project)).must_equal project

      _(result.first['name']).must_equal name_fact.name.name
      _(result.first['data']).must_equal [50, 8, 5]
      _(result.last['name']).must_equal 'Other'
      _(result.last['data']).must_equal [0, 0, 0]
    end
  end

  describe 'commits_history' do
    it 'should return chart data' do
      monthly_commit_history = create(:monthly_commit_history, json: "{\"#{Date.current.strftime('%Y-%m-01')}\" : 1}")
      analysis = monthly_commit_history.analysis
      analysis.update_attribute(:created_at, Date.current + 32.days)

      create_all_months

      get :commits_history, params: { project_id: project.to_param, id: analysis.id }

      result = JSON.parse(@response.body)

      assert_response :ok
      _(assigns(:analysis)).must_equal analysis
      _(assigns(:project)).must_equal project

      _(result['rangeSelector']['enabled']).must_equal true
      _(result['legend']['enabled']).must_equal false
      _(result['scrollbar']['enabled']).must_equal true
      _(result['series'].first['data'].last).must_equal [time_integer, 1]
      _(result['series'].last['data'].last['x']).must_equal time_integer
      _(result['series'].last['data'].last['y']).must_equal 1
    end
  end

  describe 'committer_history' do
    it 'should return chart data' do
      create_all_months
      activity_fact.update!(month: second_day_of_month)
      create(:activity_fact, month: beginning_of_month, analysis: activity_fact.analysis)
      analysis.update!(oldest_code_set_time: Date.current + 32.days)

      get :committer_history, params: { project_id: project.to_param, id: analysis.reload.id }

      result = JSON.parse(@response.body)

      assert_response :ok
      _(assigns(:analysis)).must_equal analysis
      _(assigns(:project)).must_equal project

      _(result['series'].last['data'].last['x']).must_equal time_integer
      _(result['series'].last['data'].last['y']).must_equal 1
      _(result['series'].first['data'].last).must_equal [time_integer, 1]
      _(result['rangeSelector']['enabled']).must_equal false
      _(result['legend']['enabled']).must_equal false
      _(result['scrollbar']['enabled']).must_equal false
    end
  end

  describe 'contributor_summary' do
    it 'should return chart data' do
      create_all_months
      activity_fact.update_attribute(:month, second_day_of_month)
      create(:activity_fact, month: beginning_of_month, analysis: activity_fact.analysis)
      analysis.update(oldest_code_set_time: Date.current + 32.days)

      get :contributor_summary, params: { project_id: project.to_param, id: analysis.reload.id }

      result = JSON.parse(@response.body)

      assert_response :ok
      _(assigns(:analysis)).must_equal analysis
      _(assigns(:project)).must_equal project

      _(result['series'].last['data'].last['x']).must_equal time_integer
      _(result['series'].last['data'].last['y']).must_equal 1
      _(result['series'].first['data'].last).must_equal [time_integer, 1]
    end
  end

  describe 'language_history' do
    it 'should return chart data' do
      fact_values = { code_added: 10, code_removed: 5, comments_added: 20, comments_removed: 10, on_trunk: true,
                      blanks_added: 10, blanks_removed: 7, month: 2.months.ago.beginning_of_month }
      activity_fact.update(fact_values)
      create(:all_month, month: 2.months.ago.beginning_of_month)
      activity_fact.analysis.update(min_month: 3.months.ago.beginning_of_month)

      get :language_history, params: { project_id: project.to_param, id: analysis.id }

      result = JSON.parse(@response.body)

      assert_response :ok
      _(assigns(:analysis)).must_equal analysis
      _(assigns(:project)).must_equal project

      _(result['series'].first['name']).must_equal activity_fact.language.nice_name
      _(result['series'].first['color']).must_equal '#EEE'
      _(result['series'].first['data']).must_equal [[time_integer, 5]]
    end
  end

  describe 'code_history' do
    it 'should return chart data' do
      options = { code_added: 10, code_removed: 5, comments_added: 20, comments_removed: 10,
                  blanks_added: 10, blanks_removed: 7, month: 1.month.ago.beginning_of_month }
      activity_fact.update(options)
      create(:all_month, month: 1.month.ago.beginning_of_month)
      analysis.update(min_month: 2.months.ago.beginning_of_month, max_month: beginning_of_month)

      get :code_history, params: { project_id: project.to_param, id: analysis.id }

      result = JSON.parse(@response.body)

      assert_response :ok
      _(assigns(:analysis)).must_equal analysis
      _(assigns(:project)).must_equal project

      series = result['series']

      _(series.first['id']).must_equal 'code'
      _(series.map { |d| d['data'].last }).must_equal [[time_integer, 5], [time_integer, 10], [time_integer, 3]]
      _(series.map { |d| d['name'] }).must_equal %w[Code Comments Blanks]
      _(result['scrollbar']).must_be_nil
    end
  end

  describe 'lines_of_code' do
    it 'should return chart data' do
      options = { code_added: 10, code_removed: 5, comments_added: 20, comments_removed: 10,
                  blanks_added: 10, blanks_removed: 7, month: 2.months.ago.beginning_of_month }
      activity_fact.update(options)
      create(:all_month, month: 2.months.ago.beginning_of_month)
      activity_fact.analysis.update(min_month: 3.months.ago.beginning_of_month)

      get :lines_of_code, params: { project_id: project.to_param, id: analysis.id }

      result = JSON.parse(@response.body)

      assert_response :ok
      _(assigns(:analysis)).must_equal analysis
      _(assigns(:project)).must_equal project

      series = result['series']

      _(series.first['id']).must_equal 'code'
      _(series.map { |d| d['data'].last }).must_equal [[time_integer, 5], [time_integer, 10], [time_integer, 3]]
      _(series.map { |d| d['name'] }).must_equal %w[Code Comments Blanks]
      _(result['scrollbar']['enabled']).must_equal false
    end
  end

  describe 'commits_spark' do
    it 'should return spark image' do
      Spark::SimpleSpark.any_instance.stubs(:width).returns(100)
      get :commits_spark, params: { project_id: project.to_param, id: analysis.id }

      assert_response :ok
      _(assigns(:project)).must_equal project
      _(assigns(:analysis)).must_equal analysis
    end
  end

  describe 'languages' do
    it 'should return pie chart' do
      data = [[1, 'XMl', { vanity_url: 'xml', percent: 30, color: '555555' }],
              [2, 'SQL', { vanity_url: 'sql', percent: 23, color: '493625' }],
              [3, 'HTML', { vanity_url: 'html', percent: 20, color: '47A400' }],
              [nil, '3 Other', { vanity_url: 'xml', percent: 27, color: '555555' }]]

      Analysis::LanguagePercentages.any_instance.stubs(:collection).returns(data)

      get :languages, params: { project_id: project.to_param, id: analysis.id }

      assert_response :ok
      _(assigns(:analysis)).must_equal analysis
      _(assigns(:project)).must_equal project
    end
  end
end
