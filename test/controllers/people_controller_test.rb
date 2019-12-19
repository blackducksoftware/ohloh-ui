# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/commits_by_language_data'
require 'support/unclaimed_controller_test'

describe 'PeopleControllerTest' do
  before do
    Account.destroy_all
    Person.destroy_all
    account = create(:account, name: 'Bubba Hotep')
    best_vita = create(:best_vita, account: account)
    account.update(best_vita_id: best_vita.id)
    @claimed = create(:person, kudo_score: 12, kudo_rank: 3)
    @claimed.update(id: account.id, account_id: account.id)
    @unclaimed = create(:person, kudo_score: 12, kudo_rank: 3, effective_name: 'Bubba Amon')
    @project1 = create(:project)
    @project2 = create(:project)
    best_vita.vita_fact.update_column(:commits_by_language, CommitsByLanguageData.construct)
    create(:name_fact, analysis_id: @project1.best_analysis_id, name_id: @unclaimed.name.id)
    create(:name_fact, analysis_id: @project2.best_analysis_id, name_id: @unclaimed.name.id)
    @unclaimed.name.update(name: 'Bubba Amon')
  end

  describe 'index' do
    it 'should render the people found' do
      get :index, query: 'Bubba'
      must_respond_with :ok
      response.body.must_match @claimed.account.name
      response.body.must_match @unclaimed.name.name
    end

    it 'must limit results when it exceeds OBJECT_MEMORY_CAP' do
      UnclaimedControllerTest.limit_by_memory_cap(self)
    end

    it 'should render the people page' do
      get :index
      must_respond_with :ok
      must_render_template :index
    end
  end

  describe 'rankings' do
    it 'should render the people found' do
      get :rankings, query: 'Bubba'
      must_respond_with :ok
      response.body.must_match @claimed.account.name
      response.body.must_match @unclaimed.name.name
    end
  end
end
