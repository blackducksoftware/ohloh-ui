require 'test_helper'

describe 'AliasesController' do
  before do
    Project.any_instance.stubs(:code_locations).returns([])
    Enlistment.any_instance.stubs(:code_location).returns(code_location_stub)
    @account = create(:account)
    @project = create(:project)
    @commit_name = create(:name)
    @preferred_name = create(:name)
    @alias = create(:alias, project_id: @project.id, commit_name_id: @commit_name.id,
                            preferred_name_id: @preferred_name.id)
    enlistment = create_enlistment_with_code_location
    code_set = create(:code_set, code_location_id: enlistment.code_location_id)
    code_location = CodeLocation.new(id: enlistment.code_location_id, url: 'url')
    Project.any_instance.stubs(:code_locations).returns([code_location])
    CodeSet.any_instance.stubs(:code_location).returns(code_location)
    @commit = create(:commit, code_set: code_set)
    @commit_project = enlistment.project
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
      assert_nil assigns(:committer_names)
    end

    it 'must render projects/deleted when project is deleted' do
      login_as @account
      ApplicationController.any_instance.stubs(:current_user_can_manage?).returns(true)
      @project.update!(deleted: true, editor_account: @account)

      get :new, project_id: @project.id

      must_render_template 'deleted'
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
      before = Alias.count
      post :create, project_id: @project.id, commit_name_id: create(:name).id, preferred_name_id: create(:name).id
      Alias.count.must_equal(before + 1)
      must_respond_with :redirect
      must_redirect_to action: :index
    end

    it 'handles invalid params' do
      login_as @account
      before = Alias.count
      post :create, project_id: @project.id, commit_name_id: create(:name).id
      Alias.count.must_equal(before)
      must_respond_with :unprocessable_entity
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
