# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/activity_facts_by_commits_data'
require 'test_helpers/create_contributions_data'

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
    it 'should return contributions' do
      get :index, project_id: @project.to_param, sort: 'latest_commit'

      must_respond_with :ok
      assigns(:contributions).must_equal [@contribution]
    end

    it 'should return contributions with valid search param' do
      get :index, project_id: @project.to_param, sort: 'latest_commit', query: @person.effective_name

      must_respond_with :ok
      assigns(:contributions).must_equal [@contribution]
    end

    it 'should not return contributions with invalid search param' do
      get :index, project_id: @project.to_param, sort: 'latest_commit', query: 'dummy'

      must_respond_with :ok
      assigns(:contributions).must_equal []
    end

    it 'should return contributions within 30 days' do
      contributions = create_contributions(@project)
      get :index, project_id: @project.to_param, sort: 'latest_commit', time_span: '30 days'

      must_respond_with :ok
      assigns(:contributions).size.must_equal 2
      assigns(:contributions).must_include contributions[0]
      assigns(:contributions).must_include contributions[1]
    end

    it 'should return contributions within 12 months' do
      contributions = create_contributions(@project)
      get :index, project_id: @project.to_param, sort: 'latest_commit', time_span: '12 months'

      must_respond_with :ok
      assigns(:contributions).size.must_equal 3
      assigns(:contributions).must_include contributions[0]
      assigns(:contributions).must_include contributions[1]
      assigns(:contributions).must_include contributions[2]
    end

    it 'should return contributions in xml format with valid api key' do
      @contributor_fact.first_checkin = Date.current
      @contributor_fact.last_checkin = Date.current
      @contributor_fact.save
      key = create(:api_key, account_id: create(:account).id)
      get :index, project_id: @project.to_param, api_key: key.oauth_application.uid, format: :xml
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

    it 'wont show unclaimed positions as inactive' do
      get :summary, project_id: @project.to_param

      must_respond_with :ok
      @project.contributions.where('position_id IS NOT NULL').must_be :empty?
      response.body.wont_match(I18n.t('contributions.contributions.inactive'))
    end
  end

  describe 'show' do
    let(:api_key) { create(:api_key) }
    let(:client_id) { api_key.oauth_application.uid }

    it 'should return contribution' do
      ContributorFact.any_instance.stubs(:first_checkin).returns(Time.current - 2.days)
      ContributorFact.any_instance.stubs(:last_checkin).returns(Time.current)

      get :show, project_id: @project.to_param, id: @contribution.id

      must_respond_with :ok
      assigns(:contribution).must_equal @contribution
      assigns(:recent_kudos).must_equal @contribution.recent_kudos
    end

    it 'should support being called via the api' do
      ContributorFact.any_instance.stubs(:first_checkin).returns(Time.current - 2.days)
      ContributorFact.any_instance.stubs(:last_checkin).returns(Time.current)

      key = create(:api_key, account_id: create(:account).id)
      get :show, project_id: @project.to_param, id: @contribution.id, format: :xml, api_key: key.oauth_application.uid

      must_respond_with :ok
    end

    it 'must render projects/deleted for deleted projects' do
      @project.update!(deleted: true, editor_account: create(:account))

      get :show, project_id: @project.to_param, id: @contribution.id

      must_render_template 'deleted'
    end

    it 'must render projects/deleted for deleted projects using xml api' do
      @project.update!(deleted: true, editor_account: create(:account))

      get :show, project_id: @project.to_param, id: @contribution.id, format: :xml, api_key: client_id

      must_render_template 'deleted'
    end

    it 'must handle non existent projects via xml api' do
      get :show, project_id: 'non-existent', id: @contribution.id, format: :xml, api_key: client_id

      must_render_template 'error.xml'
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
      name_fact = create(:name_fact, analysis: project.best_analysis, name: name, vita_id: create(:account_analysis).id)
      name_fact.account_analysis.account.update(best_vita_id: name_fact.vita_id, latitude: 30.26, longitude: -97.74)
      create(:position, project: project, name: name, account: name_fact.account_analysis.account)
      get :near, project_id: project.to_param, lat: 25, lng: 12, zoom: 2
      must_respond_with :success
      resp = JSON.parse(response.body)
      resp['accounts'].length.must_equal 1
      resp['accounts'][0]['id'].must_equal name_fact.account_analysis.account.id
      resp['accounts'][0]['latitude'].must_equal name_fact.account_analysis.account.latitude.to_s
      resp['accounts'][0]['longitude'].must_equal name_fact.account_analysis.account.longitude.to_s
    end

    it 'near should support zoomed in values' do
      login_as nil
      project = create(:project)
      name = create(:name)
      name_fact = create(:name_fact, analysis: project.best_analysis, name: name, vita_id: create(:account_analysis).id)
      name_fact.account_analysis.account.update(best_vita_id: name_fact.vita_id, latitude: 30.26, longitude: -97.74)
      create(:position, project: project, name: name, account: name_fact.account_analysis.account)
      get :near, project_id: project.to_param, lat: 25, lng: 12, zoom: 4
      must_respond_with :success
      resp = JSON.parse(response.body)
      resp['accounts'].length.must_equal 1
      resp['accounts'][0]['id'].must_equal name_fact.account_analysis.account.id
      resp['accounts'][0]['latitude'].must_equal name_fact.account_analysis.account.latitude.to_s
      resp['accounts'][0]['longitude'].must_equal name_fact.account_analysis.account.longitude.to_s
    end
  end
end
