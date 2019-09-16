# frozen_string_literal: true

require 'test_helper'

describe 'PositionFactoriesController' do
  let(:account) { create(:account) }

  describe 'create' do
    it 'must render error for logged out user' do
      post :create, account_id: account.to_param

      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'wont allow for other accounts' do
      login_as(account)
      other_account = create(:account)

      post :create, account_id: other_account.to_param

      must_redirect_to new_session_path
    end

    it 'must check for valid project_name' do
      login_as(account)
      post :create, account_id: account.to_param

      must_redirect_to projects_path
      flash[:error].must_equal I18n.t('position_factories.create.project_not_found', name: '')
    end

    it 'must check for valid committer_name' do
      login_as(account)
      project = create(:project)
      post :create, account_id: account.to_param, project_name: project.name, committer_name: 'NonExistent'

      must_redirect_to project_contributors_path(project)
      flash[:error].must_equal I18n.t('position_factories.create.contributor_not_found', name: 'NonExistent')
    end

    describe 'current user already has a valid position' do
      it 'must create an alias' do
        project = create(:project)
        name1 = create(:name)
        name2 = create(:name)

        create_position(account: account, name: name1, project: project)
        Alias.expects(:create).returns(Alias.new(preferred_name: name1))

        login_as(account)
        post :create, account_id: account.to_param, project_name: project.name, committer_name: name2.name

        must_redirect_to account_positions_path(account)
        flash[:success].must_equal I18n.t('position_factories.create.rename_commit_author',
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
        post :create, account_id: account.to_param, project_name: project.name, committer_name: name2.name

        must_redirect_to account_positions_path(account)
        flash[:success].must_equal I18n.t('position_factories.create.rename_commit_author',
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
      post :create, account_id: account.to_param, project_name: project.name, committer_name: new_name.name

      must_redirect_to account_positions_path(account)

      Position.find_by(name: old_name).wont_be :present?
      new_position = account.positions.first
      new_position.project.must_equal project
      new_position.name.must_equal new_name
    end

    it 'must successfully render new position page' do
      project = create(:project)
      name = create(:name)
      Account::PositionCore.any_instance.stubs(:ensure_position_or_alias!)
      login_as(account)

      post :create, account_id: account.to_param, project_name: project.name, committer_name: name.name

      must_redirect_to new_account_position_path(account, project_name: project.name, committer_name: name.name)
      account.positions.first.must_be_nil
      flash[:success].must_equal I18n.t('position_factories.create.success', name: CGI.escapeHTML(name.name))
    end
  end
end
