# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/commits_by_project_data'
require 'test_helpers/commits_by_language_data'

class Accounts::ChartsControllerTest < ActionController::TestCase
  let(:account) { create_account_with_commits_by_project }
  let(:position1) { account.positions.first }
  let(:position2) { account.positions.last }
  let(:admin) { create(:admin) }

  before do
    login_as admin
  end

  describe 'commits_by_project' do
    it 'should return json chart data' do
      get :commits_by_project, params: { account_id: account.id }
      result = JSON.parse(response.body)

      assert_response :ok
      _(result['noCommits']).must_equal false
      _(result['series'].first['data']).must_equal ([nil] * 13) + [25, 40, 28, 18, 1, 8, 26, 9] + ([nil] * 64)
      _(result['series'].first['name']).must_equal position1.project.name
    end

    it 'should redirect if account is disabled' do
      Account::Access.any_instance.stubs(:disabled?).returns(true)

      get :commits_by_project, params: { account_id: admin.login }
      assert_redirected_to disabled_account_url(admin)
    end
  end

  describe 'commits_by_individual_project' do
    it 'should return json chart data' do
      get :commits_by_individual_project,
          params: { account_id: account.id, project_id: account.positions.first.project.id }
      result = JSON.parse(response.body)

      assert_response :ok
      _(result['series'].first['data']).must_equal [25, 40, 28, 18, 1, 8, 26, 9] + ([0] * 64)
    end

    it 'should redirect if account is disabled' do
      Account::Access.any_instance.stubs(:disabled?).returns(true)

      get :commits_by_individual_project, params: { account_id: admin.login }
      assert_redirected_to disabled_account_url(admin)
    end
  end

  describe 'commits_by_language' do
    it 'should return json chart data when scope is regular' do
      get :commits_by_language, params: { account_id: account.id, scope: 'regular' }
      result = JSON.parse(response.body)

      first_lanugage = result['object_array'].first['table']
      assert_response :ok
      _(first_lanugage['language_id']).must_equal '17'
      _(first_lanugage['name']).must_equal 'csharp'
      _(first_lanugage['color_code']).must_equal '4096EE'
      _(first_lanugage['nice_name']).must_equal 'C#'
      _(first_lanugage['commits']).must_equal ([0] * 12) + [24, 37, 27, 16, 1, 8, 26, 9] + ([0] * 64)
      _(first_lanugage['category']).must_equal '0'
    end

    it 'should redirect if account is disabled' do
      Account::Access.any_instance.stubs(:disabled?).returns(true)

      get :commits_by_language, params: { account_id: admin.login }
      assert_redirected_to disabled_account_url(admin)
    end
  end
end
