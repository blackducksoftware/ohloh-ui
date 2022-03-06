# frozen_string_literal: true

require 'test_helper'

class PositionFactoriesControllerTest < ActionController::TestCase
  let(:account) { create(:account) }

  describe 'create' do
    it 'must render error for logged out user' do
      post :create, params: { account_id: account.to_param }

      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'wont allow for other accounts' do
      login_as(account)
      other_account = create(:account)

      post :create, params: { account_id: other_account.to_param }

      assert_redirected_to new_session_path
    end

    it 'must check for valid project_name' do
      login_as(account)
      post :create, params: { account_id: account.to_param }

      assert_redirected_to projects_path
      _(flash[:error]).must_equal I18n.t('position_factories.create.project_not_found', name: '')
    end

    it 'must check for valid committer_name' do
      login_as(account)
      project = create(:project)
      post :create, params: { account_id: account.to_param, project_name: project.name, committer_name: 'NonExistent' }

      assert_redirected_to project_contributors_path(project)
      _(flash[:error]).must_equal I18n.t('position_factories.create.contributor_not_found', name: 'NonExistent')
    end

    describe 'current user already has a valid position' do
      it 'must create an alias' do
        project = create(:project)
        name1 = create(:name)
        name2 = create(:name)

        create_position(account: account, name: name1, project: project)
        Alias.expects(:create).returns(Alias.new(preferred_name: name1))

        login_as(account)
        post :create, params: { account_id: account.to_param, project_name: project.name, committer_name: name2.name }

        assert_redirected_to account_positions_path(account)
        _(flash[:success]).must_equal I18n.t('position_factories.create.rename_commit_author',
                                             name: name2.name, preferred_name: name1.name)
      end

      # Covers the case in which the user already has a position, and is trying to claim a second name.
      # Additionally, the project manager has locked the project permissions to prevent edits.
      it 'must create an alias even if project edits are locked' do
        project = create(:project)
        create(:manage, account: account, target: project)
        create(:permission, target: project, remainder: true)

        name1 = create(:name)
        name2 = create(:name)

        create_position(account: account, name: name1, project: project)
        Alias.expects(:create).returns(Alias.new(preferred_name: name1))

        login_as(account)
        post :create, params: { account_id: account.to_param, project_name: project.name, committer_name: name2.name }

        assert_redirected_to account_positions_path(account)
        _(flash[:success]).must_equal I18n.t('position_factories.create.rename_commit_author',
                                             name: name2.name, preferred_name: name1.name)
      end
    end

    # Existing position becomes invalid in cases like when the repository switches from CVS to Git,
    # so the committer name doesn't exist in the project anymore.
    it 'must recreate position if existing position is invalid' do
      old_name = create(:name)
      new_name = create(:name)
      project = create(:project)
      create_position(project: project, name: old_name, account: account)
      NameFact.find_by(name: old_name).destroy
      NameFact.create!(analysis: project.best_analysis, name: new_name)

      login_as(account)
      post :create, params: { account_id: account.to_param, project_name: project.name, committer_name: new_name.name }

      assert_redirected_to account_positions_path(account)

      _(Position.find_by(name: old_name)).wont_be :present?
      new_position = account.positions.first
      _(new_position.project).must_equal project
      _(new_position.name).must_equal new_name
    end

    it 'must successfully render new position page' do
      project = create(:project)
      name = create(:name)
      Account::PositionCore.any_instance.stubs(:ensure_position_or_alias!)
      login_as(account)

      post :create, params: { account_id: account.to_param, project_name: project.name, committer_name: name.name }

      assert_redirected_to new_account_position_path(account, project_name: project.name, committer_name: name.name)
      _(account.positions.first).must_be_nil
      _(flash[:success]).must_equal I18n.t('position_factories.create.success', name: CGI.escapeHTML(name.name))
    end
  end
end
