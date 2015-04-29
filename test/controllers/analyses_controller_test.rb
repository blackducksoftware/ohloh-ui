require 'test_helper'
require 'test_helpers/xml_parsing_helpers'

describe 'AnalysesController' do
  let(:beginning_of_month) { Date.today.to_time.beginning_of_month }
  let(:account) { create(:account) }
  let(:activity_fact) { create(:activity_fact, code_added: 5, code_removed: 3, blanks_added: 3, blanks_removed: 0) }
  let(:activity_fact_2) do
    options = { analysis: activity_fact.analysis, code_added: 6, code_removed: 5, blanks_added: 5, blanks_removed: 4 }
    create(:activity_fact, options)
  end
  let(:analysis) do
    activity_fact_2.analysis.update_attributes(updated_on: Date.today, logged_at: Date.today)
    activity_fact_2.analysis
  end
  let(:project) { analysis.project }
  let(:api_key) { create(:api_key, account_id: account.id, daily_limit: 100) }
  let(:date_range) { [3.months.ago, 2.months.ago, 1.month.ago, Date.today].map(&:beginning_of_month) }
  let(:create_all_months) do
    AllMonth.delete_all
    date_range.each { |date| create(:all_month, month: date) }
  end
  let(:time_integer) { AllMonth.all.to_a.last.month.utc.to_i * 1000 }

  describe 'show' do
    it 'should redirect to project page for html request' do
      get :show, project_id: project.to_param, id: analysis.id
      must_redirect_to project_path(project)
    end

    it 'should respond with 401 if api_key is wrong' do
      get :show, project_id: project.to_param, id: analysis.id, format: :xml, api_key: 'badkey'
      must_respond_with :unauthorized
    end

    it 'should redirect to project page for html request' do
      url = "http://test.host/p/#{project.url_name}/analyses/#{analysis.id}"

      get :show, project_id: project.to_param, id: analysis.id, format: :xml, api_key: api_key.key

      result = xml_hash(@response.body)['response']
      analysis_result = result['result']['analysis']

      must_respond_with :ok
      result['status'].must_equal 'success'
      analysis_result['id'].must_equal analysis.id.to_s
      analysis_result['url'].must_equal "#{url}.xml"
      analysis_result['project_id'].must_equal project.id.to_s
      analysis_result['updated_at'].must_equal xml_time(Date.today)
      analysis_result['min_month'].must_equal((Date.today - 1.month).to_s)
      analysis_result['max_month'].must_equal((Date.today - 1.day).to_s)
      analysis_result['twelve_month_contributor_count'].must_equal nil
      analysis_result['total_contributor_count'].must_equal nil
      analysis_result['twelve_month_commit_count'].must_equal '4'
      analysis_result['total_commit_count'].must_equal nil
      analysis_result['total_code_lines'].must_equal '303'
      analysis_result['languages']['graph_url'].must_equal "#{url}/languages.png"
      analysis_result['main_language_id'].must_equal analysis.main_language.id.to_s
      analysis_result['main_language_name'].must_equal analysis.main_language.nice_name
    end
  end

  describe 'languages_summary' do
    it 'should set the language_breakdown data' do
      activity_fact_2.update!(language: activity_fact.language)
      get :languages_summary, project_id: project.to_param, id: analysis.id

      must_respond_with :ok
      assigns(:analysis).must_equal analysis
      assigns(:project).must_equal project
      assigns(:languages_breakdown).first.code_total.must_equal 3
      assigns(:languages_breakdown).first.blanks_total.must_equal 4
    end
  end

  describe 'top_commit_volume_chart' do
    it 'should return chart data json' do
      name_fact = create(:name_fact, thirty_day_commits: 5, twelve_month_commits: 8, commits: 50)
      analysis = name_fact.analysis
      get :top_commit_volume_chart, project_id: project.to_param, id: analysis.id

      result = JSON.parse(@response.body)['series']

      must_respond_with :ok
      assigns(:analysis).must_equal analysis
      assigns(:project).must_equal project

      result.first['name'].must_equal name_fact.name.name
      result.first['data'].must_equal [50, 8, 5]
      result.last['name'].must_equal 'Other'
      result.last['data'].must_equal [0, 0, 0]
    end
  end

  describe 'commits_history' do
    it 'should return chart data' do
      analysis_sloc_set = create(:analysis_sloc_set, as_of: 1)
      commit = create(:commit, code_set: analysis_sloc_set.sloc_set.code_set, position: 0)
      analysis = analysis_sloc_set.analysis
      analysis.update_attribute(:created_at, Date.today + 32.days)
      create(:analysis_alias, commit_name: commit.name, analysis: analysis)
      create_all_months

      get :commits_history, project_id: project.to_param, id: analysis.id

      result = JSON.parse(@response.body)

      must_respond_with :ok
      assigns(:analysis).must_equal analysis
      assigns(:project).must_equal project

      result['rangeSelector']['enabled'].must_equal false
      result['legend']['enabled'].must_equal false
      result['scrollbar']['enabled'].must_equal false
      result['series'].first['data'].last.must_equal [time_integer, 1]
      result['series'].last['data'].last['x'].must_equal time_integer
      result['series'].last['data'].last['y'].must_equal 1
    end
  end

  describe 'committer_history' do
    it 'should return chart data' do
      create_all_months
      activity_fact.update_attributes!(month: Date.today)
      create(:activity_fact, month: beginning_of_month, analysis: activity_fact.analysis)
      analysis.update_attributes!(logged_at: Date.today + 32.days)

      get :committer_history, project_id: project.to_param, id: analysis.reload.id

      result = JSON.parse(@response.body)

      must_respond_with :ok
      assigns(:analysis).must_equal analysis
      assigns(:project).must_equal project

      result['series'].last['data'].last['x'].must_equal time_integer
      result['series'].last['data'].last['y'].must_equal 1
      result['series'].first['data'].last.must_equal [time_integer, 1]
      result['rangeSelector']['enabled'].must_equal false
      result['legend']['enabled'].must_equal false
      result['scrollbar']['enabled'].must_equal false
    end
  end

  describe 'contributor_summary' do
    it 'should return chart data' do
      create_all_months
      activity_fact.update_attribute(:month, Date.today)
      create(:activity_fact, month: beginning_of_month, analysis: activity_fact.analysis)
      analysis.update_attributes(logged_at: Date.today + 32.days)

      get :contributor_summary, project_id: project.to_param, id: analysis.reload.id

      result = JSON.parse(@response.body)

      must_respond_with :ok
      assigns(:analysis).must_equal analysis
      assigns(:project).must_equal project

      result['series'].last['data'].last['x'].must_equal time_integer
      result['series'].last['data'].last['y'].must_equal 1
      result['series'].first['data'].last.must_equal [time_integer, 1]
    end
  end

  describe 'language_history' do
    it 'should return chart data' do
      fact_values = { code_added: 10, code_removed: 5, comments_added: 20, comments_removed: 10, on_trunk: true,
                      blanks_added: 10, blanks_removed: 7, month: 2.months.ago.beginning_of_month.advance(days: 5) }
      activity_fact.update_attributes(fact_values)
      create_all_months

      get :language_history, project_id: project.to_param, id: analysis.id

      result = JSON.parse(@response.body)

      must_respond_with :ok
      assigns(:analysis).must_equal analysis
      assigns(:project).must_equal project

      result['series'].first['name'].must_equal activity_fact.language.nice_name
      result['series'].first['color'].must_equal '#EEE'
      result['series'].first['data'].must_equal [[time_integer, 5]]
    end
  end

  describe 'code_history' do
    it 'should return chart data' do
      options = { code_added: 10, code_removed: 5, comments_added: 20, comments_removed: 10,
                  blanks_added: 10, blanks_removed: 7, month: 2.months.ago.beginning_of_month.advance(days: 5) }
      activity_fact.update_attributes(options)
      activity_fact_2
      create_all_months

      get :code_history, project_id: project.to_param, id: analysis.id

      result = JSON.parse(@response.body)

      must_respond_with :ok
      assigns(:analysis).must_equal analysis
      assigns(:project).must_equal project

      series = result['series']
      chart_options = result['chart']

      series.first['id'].must_equal 'code'
      series.map { |d| d['data'].last }.must_equal [[time_integer, 5], [time_integer, 10], [time_integer, 3]]
      series.map { |d| d['name'] }.must_equal %w(Code Comments Blanks)
      chart_options['width'].must_equal 950
      result['scrollbar'].must_equal nil
    end
  end

  describe 'lines_of_code' do
    it 'should return chart data' do
      options = { code_added: 10, code_removed: 5, comments_added: 20, comments_removed: 10,
                  blanks_added: 10, blanks_removed: 7, month: 2.months.ago.beginning_of_month.advance(days: 5) }
      activity_fact.update_attributes(options)
      activity_fact_2
      create_all_months

      get :lines_of_code, project_id: project.to_param, id: analysis.id

      result = JSON.parse(@response.body)

      must_respond_with :ok
      assigns(:analysis).must_equal analysis
      assigns(:project).must_equal project

      series = result['series']
      chart_options = result['chart']

      series.first['id'].must_equal 'code'
      series.map { |d| d['data'].last }.must_equal [[time_integer, 5], [time_integer, 10], [time_integer, 3]]
      series.map { |d| d['name'] }.must_equal %w(Code Comments Blanks)
      chart_options['width'].must_equal 460
      result['scrollbar']['enabled'].must_equal false
    end
  end

  describe 'commits_spark' do
    it 'should return spark image' do
      Spark::SimpleSpark.any_instance.stubs(:width).returns(100)
      get :commits_spark, project_id: project.to_param, id: analysis.id

      must_respond_with :ok
      assigns(:project).must_equal project
      assigns(:analysis).must_equal analysis
    end
  end
end
