require 'test_helper'

describe 'AliasesController' do
  let(:project) { create(:project) }
  let(:account) { create(:account) }

  it 'index' do
    best = create(:analysis, project: project)
    create(:analysis, project: project)
    project.update_columns(best_analysis_id: best.id)
    name1 = create(:name)
    name2 = create(:name)
    create(:analysis_alias, analysis: best, commit_name: name1, preferred_name: name2)
    project_alias = create(:alias, project: project, commit_name: name1, preferred_name: name2)
    get :index, project_id: project.id
    must_respond_with :ok
    must_render_template :index
    assigns(:best_analysis_aliases).count.must_equal 1
    assigns(:best_analysis_aliases).first.must_equal project_alias
    assigns(:aliases).count.must_equal 1
    assigns(:aliases).first.must_equal project_alias
  end

  describe 'new' do
    it 'with login user' do
      login_as account
      commit = create(:commit)
      create(:enlistment, repository: commit.code_set.repository, project: project)
      get :new, project_id: project.id
      must_respond_with :ok
      must_render_template :new
      assigns(:committer_names).count.must_equal 1
    end

    it 'without login user' do
      get :new, project_id: project.id
      must_respond_with :unauthorized
      assigns(:committer_names).must_equal nil
    end
  end

  describe 'create' do
    it 'without user logged in' do
      post :create, project_id: project.id
      must_respond_with :unauthorized
    end

    it 'with user login' do
      project = create(:project)
      commit_name = create(:name)
      preferred_name = create(:name)
      login_as account
      lambda do
        post :create, project_id: project.id, commit_name_id: commit_name.id, preferred_name_id: preferred_name.id
      end.must_change 'Alias.count'
      must_respond_with :redirect
      must_redirect_to action: :index
    end
  end

  it 'undo' do
    login_as account
    alias_record = create(:alias)
    alias_record.deleted.must_equal false
    post :undo, project_id: project.id, id: alias_record.id
    must_respond_with :redirect
    must_redirect_to action: :index
    alias_record.reload.deleted.must_equal true
  end

  it 'redo' do
    login_as account
    alias_record = create(:alias)
    alias_record.create_edit.undo!(account)
    alias_record.reload.deleted.must_equal true
    post :redo, project_id: project.id, id: alias_record.id
    must_respond_with :redirect
    must_redirect_to action: :index
    alias_record.reload.deleted.must_equal false
  end

  it 'preferred_names' do
    login_as account
    commit = create(:commit)
    enlistment = create(:enlistment, repository: commit.code_set.repository)
    get :preferred_names, project_id: enlistment.project.id
    assigns(:preferred_names).first.must_equal commit.name
  end
end
