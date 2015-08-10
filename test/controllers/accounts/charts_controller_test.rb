require 'test_helper'
require 'test_helpers/commits_by_project_data'
require 'test_helpers/commits_by_language_data'

describe 'Accounts::ChartsController' do
  let(:account) { create(:account) }

  let(:vita_fact) do
    vita = create(:best_vita, account_id: account.id)
    account.update(best_vita_id: vita.id)
    create(:vita_fact, vita_id: vita.id)
  end

  let(:position1) { create_position(account: account) }
  let(:position2) { create_position(account: account) }

  let(:construct_cbp_data) do
    cbp = CommitsByProjectData.new(position1.id, position2.id).construct
    vita_fact.update(commits_by_project: cbp)
  end

  before do
    construct_cbp_data
  end

  let(:admin) { create(:admin) }

  describe 'commits_by_project' do
    it 'should return json chart data' do
      get :commits_by_project, account_id: account.id
      result  = JSON.parse(response.body)

      must_respond_with :ok
      result['noCommits'].must_equal false
      result['series'].first['data'].must_equal [nil] * 13 + [25, 40, 28, 18, 1, 8, 26, 9] + [nil] * 64
      result['series'].first['name'].must_equal position1.project.name
    end

    it 'should redirect if account is disabled' do
      Account::Access.any_instance.stubs(:disabled?).returns(true)

      get :commits_by_project, account_id: admin.login
      must_redirect_to disabled_account_url(admin)
    end
  end

  describe 'commits_by_individual_project' do
    it 'should return json chart data' do
      get :commits_by_individual_project, account_id: account.id, project_id: account.positions.first.project.id
      result  = JSON.parse(response.body)

      must_respond_with :ok
      result['series'].first['data'].must_equal [25, 40, 28, 18, 1, 8, 26, 9] + [0] * 64
    end

    it 'should redirect if account is disabled' do
      Account::Access.any_instance.stubs(:disabled?).returns(true)

      get :commits_by_individual_project, account_id: admin.login
      must_redirect_to disabled_account_url(admin)
    end
  end

  describe 'commits_by_language' do
    it 'should return json chart data when scope is regular' do
      vita_fact.update(commits_by_language: CommitsByLanguageData.construct)
      get :commits_by_language, account_id: account.id, scope: 'regular'
      result = JSON.parse(response.body)

      first_lanugage = result['object_array'].first['table']
      must_respond_with :ok
      first_lanugage['language_id'].must_equal '17'
      first_lanugage['name'].must_equal 'csharp'
      first_lanugage['color_code'].must_equal '4096EE'
      first_lanugage['nice_name'].must_equal 'C#'
      first_lanugage['commits'].must_equal [0] * 12 + [24, 37, 27, 16, 1, 8, 26, 9] + [0] * 64
      first_lanugage['category'].must_equal '0'
    end

    it 'should redirect if account is disabled' do
      Account::Access.any_instance.stubs(:disabled?).returns(true)

      get :commits_by_language, account_id: admin.login
      must_redirect_to disabled_account_url(admin)
    end
  end
end
