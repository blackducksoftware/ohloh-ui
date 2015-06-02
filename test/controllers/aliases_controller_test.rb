require 'test_helper'

describe 'AliasesController' do
  before do
    @account = create(:account)
    @project = create(:project)
    @commit_name = create(:name)
    @preferred_name = create(:name)
    @alias   = create(:alias, project_id: @project.id, commit_name_id: @commit_name.id,
                              preferred_name_id: @preferred_name.id)
    @commit  = create(:commit)
    @commit_project = @commit.code_set.repository.projects.first
  end

  it 'index' do
    create(:analysis_alias, analysis_id: @project.best_analysis_id,
                            commit_name_id: @commit_name.id, preferred_name_id: @preferred_name.id)
    get :index, project_id: @project.id
    must_respond_with :ok
    must_render_template :index
    assigns(:best_analysis_aliases).count.must_equal 1
    assigns(:best_analysis_aliases).first.must_equal @alias
    assigns(:aliases).count.must_equal 1
    assigns(:aliases).first.must_equal @alias
  end

  describe 'new' do
    it 'with login user' do
      login_as @account
      get :new, project_id: @commit_project.id
      must_respond_with :ok
      must_render_template :new
      # assigns(:committer_names).count.must_equal 1
    end

    it 'without login user' do
      get :new, project_id: @project.id
      must_respond_with :redirect
      must_redirect_to new_session_path
      assigns(:committer_names).must_equal nil
    end
  end

  describe 'create' do
    it 'without user logged in' do
      post :create, project_id: @project.id
      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'with user login' do
      login_as @account
      lambda do
        post :create, project_id: @project.id, commit_name_id: create(:name).id, preferred_name_id: create(:name).id
      end.must_change 'Alias.count'
      must_respond_with :redirect
      must_redirect_to action: :index
    end
  end

  it 'undo' do
    login_as @account
    @alias.deleted.must_equal false
    post :undo, project_id: @project.id, id: @alias.id
    must_respond_with :redirect
    must_redirect_to action: :index
    @alias.reload.deleted.must_equal true
  end

  it 'redo' do
    login_as @account
    @alias.create_edit.undo!(@account)
    @alias.reload.deleted.must_equal true
    post :redo, project_id: @project.id, id: @alias.id
    must_respond_with :redirect
    must_redirect_to action: :index
    @alias.reload.deleted.must_equal false
  end

  it 'preferred_names' do
    login_as @account
    get :preferred_names, project_id: @commit_project.id
    assigns(:preferred_names).first.must_equal @commit.name
  end
end
