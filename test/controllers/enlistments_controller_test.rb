require 'test_helper'

describe 'EnlistmentsControllerTest' do
  before do
    @enlistment = create(:enlistment)
    @project_id = @enlistment.project.url_name
    @account = create(:account)
  end

  describe 'index' do
    it 'should return enlistment record' do
      get :index, project_id: @project_id
      must_respond_with :ok
      must_render_template :index
      assigns(:enlistments).count.must_equal 1
      assigns(:enlistments).first.must_equal @enlistment
    end

    it 'should return if valid filter_by query' do
      get :index, project_id: @project_id, query: @enlistment.project.name
      must_respond_with :ok
      must_render_template :index
      assigns(:enlistments).count.must_equal 1
      assigns(:enlistments).first.must_equal @enlistment
    end

    it 'should not return if invalid filter query' do
      get :index, project_id: @project_id, query: 'Should Fail'
      must_respond_with :ok
      must_render_template :index
      assigns(:enlistments).count.must_equal 0
    end
  end

  it 'new' do
    login_as @account
    get :new, project_id: @project_id
    must_respond_with :ok
    must_render_template :new
  end

  it 'edit' do
    login_as @account
    get :edit, project_id: @project_id, id: @enlistment.id
    must_respond_with :ok
    must_render_template :edit
  end

  it 'update' do
    login_as @account
    put :update, project_id: @project_id, id: @enlistment.id,
                 enlistment: { ignore: 'Ignore Me' }

    must_respond_with :redirect
    must_redirect_to action: :index
    @enlistment.reload.ignore.must_equal 'Ignore Me'
  end

  it 'destroy' do
    login_as @account
    delete :destroy, id: @enlistment.id, project_id: @project_id
    must_respond_with :redirect
    must_redirect_to action: :index
    @enlistment.reload.deleted.must_equal true
  end

  describe 'create' do
    before { Repository.any_instance.stubs(:bypass_url_validation).returns(true) }

    it 'should create repository and enlistments' do
      login_as @account
      Repository.count.must_equal 1
      Enlistment.count.must_equal 2
      post :create, project_id: @project_id, repository: build(:repository, url: 'Repo1').attributes
      must_respond_with :redirect
      must_redirect_to action: :index
      Repository.count.must_equal 2
      Enlistment.count.must_equal 3
    end

    it 'should not create repo if already exist' do
      login_as @account
      Repository.count.must_equal 1
      Enlistment.count.must_equal 2
      post :create, project_id: @project_id, repository: @enlistment.repository.attributes
      must_respond_with :redirect
      must_redirect_to action: :index
      Repository.count.must_equal 1
      Enlistment.count.must_equal 2
    end

    it 'must render error for missing url' do
      login_as @account

      post :create, project_id: @project_id, repository: build(:repository, url: '').attributes

      assigns(:repository).errors.messages[:url].must_be :present?
      must_render_template :new
    end
  end

  it 'show must return valid data for xml request' do
    login_as @account
    client_id = create(:api_key).oauth_application.uid

    get :show, project_id: @project_id, id: @enlistment.id, format: :xml, api_key: client_id

    must_respond_with :ok
    must_render_template :show
  end
end
