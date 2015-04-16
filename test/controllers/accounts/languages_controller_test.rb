require 'test_helper'

describe 'Accounts::LanguagesController' do
  let(:account) { accounts(:user) }
  let(:admin) { accounts(:admin) }

  describe 'languages' do
    it 'should respond with contributions data when best vita for account is nil' do
      contribution = admin.positions.first.contribution
      project = contribution.project

      get :index, account_id: admin.id

      must_respond_with :ok
      assigns(:contributions)[project.id].must_equal [contribution]
      assigns(:vlfs).must_equal nil
      assigns(:logos_map).must_equal nil
    end

    it 'should respond with contributions and vita language facts data when best vita for account is present' do
      vita_language_fact = create(:vita_language_fact, vita: account.best_vita)
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

    it 'should not display for spammer accounts' do
      get :index, account_id: create(:spammer).to_param
      must_respond_with 302
    end
  end
end
