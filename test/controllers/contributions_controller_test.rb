require 'test_helper'

describe 'ContributionsController' do
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
      ContributorFact.any_instance.stubs(:first_checkin).returns(Time.now - 2.days)
      ContributorFact.any_instance.stubs(:last_checkin).returns(Time.now)

      get :show, project_id: @project.to_param, id: @contribution.id

      must_respond_with :ok
      assigns(:contribution).must_equal @contribution
      assigns(:recent_kudos).must_equal @contribution.recent_kudos
    end
  end

  describe 'commits_spark' do
    it 'should return contribution simple spark image' do
      @contributor_fact.update_column(:analysis_id, @project.best_analysis_id)
      get :commits_spark, project_id: @project.to_param, id: @contribution.id

      must_respond_with :ok
      assigns(:contribution).must_equal @contribution
      assigns(:contributor).must_equal @contribution.contributor_fact
    end
  end

  describe 'commits_compound_spark' do
    it 'contribution' do
      @contributor_fact.update_column(:analysis_id, @project.best_analysis_id)
      get :commits_compound_spark, project_id: @project.to_param, id: @contribution.id

      must_respond_with :ok
      assigns(:contribution).must_equal @contribution
      assigns(:contributor).must_equal @contribution
    end
  end

  describe 'near' do
    it 'should show accounts when zoom level is > 3' do
      account = create(:account, latitude: '1', longitude: '1')
      vita = create(:best_vita, account_id: account.id)
      account.update_column(:best_vita_id, vita.id)

      get :near, project_id: @project.to_param

      must_respond_with :ok
      assigns(:accounts).must_equal
    end

    it 'should show accounts when zoom level is < 3' do
      get :near, project_id: @project.to_param

      must_respond_with :ok
      assigns(:accounts).must_equal
    end
  end
end
