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

    it 'should return failed_jobs as true when there failed jobs for the project' do
      FetchJob.create(repository_id: @enlistment.repository.id, status: 3)

      get :index, project_id: @enlistment.project.id

      must_respond_with :ok
      must_render_template :index
      assigns(:failed_jobs).must_equal true
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
    before do
      Repository.any_instance.stubs(:bypass_url_validation).returns(true)
      login_as @account
    end

    let(:repository) { @enlistment.repository }

    it 'should create repository and enlistments' do
      Repository.count.must_equal 1
      Enlistment.count.must_equal 2
      post :create, project_id: @project_id, repository: build(:repository, url: 'Repo1').attributes
      must_respond_with :redirect
      must_redirect_to action: :index
      Repository.count.must_equal 2
      Enlistment.count.must_equal 3
    end

    it 'should not create repo if already exist' do
      assert_no_difference ['Repository.count', 'Enlistment.count'] do
        post :create, project_id: @project_id, repository: repository.attributes
      end

      must_redirect_to action: :index
      flash[:notice].must_equal I18n.t('enlistments.create.notice', url: repository.url)
    end

    it 'must handle duplicate urls with leading or trailing spaces' do
      Repository.any_instance.stubs(:bypass_url_validation)
      GitRepository.new.source_scm_class.any_instance.stubs(:validate_server_connection)

      assert_no_difference ['Repository.count', 'Enlistment.count'] do
        post :create, project_id: @project_id,
                      repository: repository.attributes.merge(url: " #{ repository.url } ")
      end

      must_redirect_to action: :index
      flash[:notice].must_equal I18n.t('enlistments.create.notice', url: repository.url)
    end

    it 'must handle duplicate svn urls when passed type is svn_sync' do
      repository = create(:svn_repository)
      create(:enlistment, project: Project.find_by(url_name: @project_id), repository: repository)

      assert_no_difference ['Repository.count', 'Enlistment.count'] do
        post :create, project_id: @project_id,
                      repository: repository.attributes.merge(type: 'SvnSyncRepository')
      end

      must_redirect_to action: :index
      flash[:notice].must_equal I18n.t('enlistments.create.notice', url: repository.url)
    end

    it 'must render error for missing url' do
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
