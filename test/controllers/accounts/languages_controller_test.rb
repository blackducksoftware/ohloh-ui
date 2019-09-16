# frozen_string_literal: true

require 'test_helper'

describe 'Accounts::LanguagesController' do
  let(:account) { create(:account) }
  let(:admin) { create(:admin) }

  describe 'languages' do
    it 'should respond with contributions data when best vita for account is nil' do
      create_position(account: admin)
      contribution = admin.positions.first.contribution
      project = contribution.project

      get :index, account_id: admin.id

      must_respond_with :ok
      assigns(:contributions)[project.id].must_equal [contribution]
      assert_nil assigns(:vlfs)
      assert_nil assigns(:logos_map)
    end

    it 'should respond with contributions and vita language facts data when best vita for account is present' do
      create_position(account: account)
      vita = create(:best_vita, account: account)
      account.update_column(:best_vita_id, vita.id)
      vita_language_fact = create(:vita_language_fact, vita: vita)
      most_commits_project = vita_language_fact.most_commits_project
      recent_commit_project = vita_language_fact.recent_commit_project

      contribution = account.positions.first.contribution
      project = contribution.project

      logos_map = { most_commits_project.logo_id => most_commits_project.logo,
                    recent_commit_project.logo_id => recent_commit_project.logo }

      get :index, account_id: account.id

      must_respond_with :ok
      assigns(:contributions)[project.id].must_equal [contribution]
      assigns(:vlfs).must_equal [vita_language_fact]
      assigns(:logos_map).must_equal logos_map
    end

    it 'must redirect for disabled account' do
      account = create(:account)
      login_as account
      account.access.spam!

      get :index, account_id: account.id

      must_respond_with 302
    end
  end
end
