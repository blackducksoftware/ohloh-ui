require 'test_helper'
require 'test_helpers/activity_facts_by_commits_data'

describe 'ContributionsController' do
  let(:activity_facts_by_commits_data) { ActivityFactsByMonthData.new(true).data }

  before do
    @person = create(:person)
    @contribution = @person.contributions.first
    @contributor_fact = @contribution.contributor_fact
    @analysis_alias = create(:analysis_alias, preferred_name_id: @person.name_fact.name_id,
                                              analysis_id: @contributor_fact.analysis_id,
                                              commit_name_id: @contributor_fact.name_id)
    @project = @contribution.project
  end

  describe 'index' do
    it 'should return contrubutions' do
      get :index, project_id: @project.to_param, sort: 'latest_commit'

      must_respond_with :ok
      assigns(:contributions).must_equal [@contribution]
    end

    it 'should return contributions in xml format wiht api key' do
      key = create(:api_key, account_id: create(:account).id)
      get :index, project_id: @project.to_param, api_key: key.oauth_application.uid, format: 'xml'
      must_respond_with :ok
    end
  end

  describe 'summary' do
    it 'should return top and newest contrubutions' do
      get :summary, project_id: @project.to_param

      must_respond_with :ok
      assigns(:newest_contributions).must_equal [@contribution]
      assigns(:top_contributions).must_equal [@contribution]
      assigns(:analysis).must_equal @project.best_analysis
    end
  end

  describe 'show' do
    it 'should return contribution' do
      ContributorFact.any_instance.stubs(:first_checkin).returns(Time.current - 2.days)
      ContributorFact.any_instance.stubs(:last_checkin).returns(Time.current)

      get :show, project_id: @project.to_param, id: @contribution.id

      must_respond_with :ok
      assigns(:contribution).must_equal @contribution
      assigns(:recent_kudos).must_equal @contribution.recent_kudos
    end
  end

  describe 'commits_spark' do
    it 'should return contribution simple spark image' do
      ContributorFact.any_instance.stubs(:monthly_commits).returns(activity_facts_by_commits_data)
      @contributor_fact.update_column(:analysis_id, @project.best_analysis_id)

      get :commits_spark, project_id: @project.to_param, id: @contribution.contributor_fact.name_id

      must_respond_with :ok
      assigns(:contributor).must_equal @contribution.contributor_fact
    end

    it 'should render sample image if bot' do
      ApplicationController.any_instance.stubs(:bot?).returns(true)
      Spark::SimpleSpark.any_instance.expects(:render).never

      ContributorFact.any_instance.stubs(:monthly_commits).returns(activity_facts_by_commits_data)
      @contributor_fact.update_column(:analysis_id, @project.best_analysis_id)

      get :commits_spark, project_id: @project.to_param, id: @contribution.contributor_fact.name_id

      must_respond_with :ok
    end
  end

  describe 'commits_compound_spark' do
    it 'should return contribution compound spark image' do
      ContributorFact.any_instance.stubs(:monthly_commits).returns(activity_facts_by_commits_data)

      @contributor_fact.update_column(:analysis_id, @project.best_analysis_id)

      get :commits_compound_spark, project_id: @project.to_param, id: @contribution.contributor_fact.name_id

      must_respond_with :ok
      assigns(:contributor).must_equal @contributor_fact
    end

    it 'should render sample image if bot' do
      ApplicationController.any_instance.stubs(:bot?).returns(true)
      Spark::CompoundSpark.any_instance.expects(:render).never

      ContributorFact.any_instance.stubs(:monthly_commits).returns(activity_facts_by_commits_data)
      @contributor_fact.update_column(:analysis_id, @project.best_analysis_id)

      get :commits_compound_spark, project_id: @project.to_param, id: @contribution.contributor_fact.name_id

      must_respond_with :ok
    end
  end

  describe 'near' do
    it 'near should display for unlogged in users' do
      login_as nil
      project = create(:project)
      name = create(:name)
      name_fact = create(:name_fact, analysis: project.best_analysis, name: name, vita_id: create(:vita).id)
      name_fact.vita.account.update_attributes(best_vita_id: name_fact.vita_id, latitude: 30.26, longitude: -97.74)
      create(:position, project: project, name: name, account: name_fact.vita.account)
      get :near, project_id: project.to_param, lat: 25, lng: 12, zoom: 2
      must_respond_with :success
      resp = JSON.parse(response.body)
      resp['accounts'].length.must_equal 1
      resp['accounts'][0]['id'].must_equal name_fact.vita.account.id
      resp['accounts'][0]['latitude'].must_equal name_fact.vita.account.latitude.to_s
      resp['accounts'][0]['longitude'].must_equal name_fact.vita.account.longitude.to_s
    end

    it 'near should support zoomed in values' do
      login_as nil
      project = create(:project)
      name = create(:name)
      name_fact = create(:name_fact, analysis: project.best_analysis, name: name, vita_id: create(:vita).id)
      name_fact.vita.account.update_attributes(best_vita_id: name_fact.vita_id, latitude: 30.26, longitude: -97.74)
      create(:position, project: project, name: name, account: name_fact.vita.account)
      get :near, project_id: project.to_param, lat: 25, lng: 12, zoom: 4
      must_respond_with :success
      resp = JSON.parse(response.body)
      resp['accounts'].length.must_equal 1
      resp['accounts'][0]['id'].must_equal name_fact.vita.account.id
      resp['accounts'][0]['latitude'].must_equal name_fact.vita.account.latitude.to_s
      resp['accounts'][0]['longitude'].must_equal name_fact.vita.account.longitude.to_s
    end
  end
end
