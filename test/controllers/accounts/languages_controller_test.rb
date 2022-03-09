# frozen_string_literal: true

require 'test_helper'

class Accounts::LanguagesControllerTest < ActionController::TestCase
  let(:account) { create(:account) }
  let(:admin) { create(:admin) }

  describe 'languages' do
    it 'should respond with contributions data when best account_analysis for account is nil' do
      create_position(account: admin)
      contribution = admin.positions.first.contribution
      project = contribution.project

      get :index, params: { account_id: admin.id }

      assert_response :ok
      _(assigns(:contributions)[project.id]).must_equal [contribution]
      _(assigns(:vlfs)).must_be_nil
      _(assigns(:logos_map)).must_be_nil
    end

    it 'should respond with contributions & language facts data when best account_analysis for account is present' do
      create_position(account: account)
      account_analysis = create(:best_account_analysis, account: account)
      account.update_column(:best_vita_id, account_analysis.id)
      account_analysis_language_fact = create(:account_analysis_language_fact, account_analysis: account_analysis)
      most_commits_project = account_analysis_language_fact.most_commits_project
      recent_commit_project = account_analysis_language_fact.recent_commit_project

      contribution = account.positions.first.contribution
      project = contribution.project

      logos_map = { most_commits_project.logo_id => most_commits_project.logo,
                    recent_commit_project.logo_id => recent_commit_project.logo }

      get :index, params: { account_id: account.id }

      assert_response :ok
      _(assigns(:contributions)[project.id]).must_equal [contribution]
      _(assigns(:vlfs)).must_equal [account_analysis_language_fact]
      _(assigns(:logos_map)).must_equal logos_map
    end

    it 'must redirect for disabled account' do
      account = create(:account)
      login_as account
      account.access.spam!

      get :index, params: { account_id: account.id }

      assert_response 302
    end
  end
end
