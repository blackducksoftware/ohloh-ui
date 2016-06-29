require 'test_helper'

describe 'EnlistmentsControllerTest' do
  before do
    @enlistment = create(:enlistment)
    @project_id = @enlistment.project.vanity_url
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

    it 'must render projects/deleted when project is deleted' do
      login_as @account
      ApplicationController.any_instance.stubs(:current_user_can_manage?).returns(true)
      project = @enlistment.project
      project.update!(deleted: true, editor_account: @account)

      get :index, project_id: project.id

      must_render_template 'deleted'
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

    it 'must notify errors in github username' do
      Repository.any_instance.stubs(:bypass_url_validation).returns(true)

      stub_github_user_repositories_call do
        Repository.count.must_equal 1

        username = 'github.com/stan'
        post :create, project_id: @project_id, repository: GithubUser.new(url: username).attributes

        assigns(:repository).errors.messages[:url].first.must_equal I18n.t('invalid_github_username')
        must_render_template :new
        Repository.count.must_equal 1
      end
    end

    it 'must create multiple enlistments using github username' do
      Repository.any_instance.stubs(:bypass_url_validation).returns(true)

      stub_github_user_repositories_call do
        project = Project.from_param(@project_id).take
        Repository.count.must_equal 1
        project.enlistments.count.must_equal 1

        username = 'stan'
        post :create, project_id: @project_id, repository: GithubUser.new(url: username).attributes
        must_respond_with :redirect
        must_redirect_to action: :index

        flash[:notice].must_equal I18n.t('enlistments.create.github_repos_added', username: username)
        Repository.count.must_equal 5
        project.enlistments.count.must_equal 5
      end
    end

    it 'must create enlistment for any existing repository' do
      Repository.any_instance.stubs(:bypass_url_validation).returns(true)
      username = 'stan'
      GitRepository.create!(url: "git://github.com/#{username}/sablon.git")

      stub_github_user_repositories_call do
        project = Project.from_param(@project_id).take
        Repository.count.must_equal 2
        project.enlistments.count.must_equal 1

        post :create, project_id: @project_id, repository: GithubUser.new(url: username).attributes

        Repository.count.must_equal 5
        project.enlistments.count.must_equal 5
      end
    end

    it 'must create repository, enlistments and code_location' do
      Repository.count.must_equal 1
      Enlistment.count.must_equal 2
      traits = build(:repository, url: 'Repo1').attributes
                                               .merge(prime_code_location_attributes: { branch_name: :master })
      post :create, project_id: @project_id, repository: traits
      must_respond_with :redirect
      must_redirect_to action: :index
      Repository.count.must_equal 2
      Enlistment.count.must_equal 3
      repository = Repository.last
      repository.code_locations.count.must_equal 1
      repository.prime_code_location_id.must_equal CodeLocation.last.id
    end

    it 'must show alert message for adding the first enlistment' do
      post :create, project_id: @project_id, repository: repository.attributes

      must_redirect_to action: :index

      flash[:show_first_enlistment_alert].must_be :present?
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
                      repository: repository.attributes.merge(url: " #{repository.url} ")
      end

      must_redirect_to action: :index
      flash[:notice].must_equal I18n.t('enlistments.create.notice', url: repository.url)
    end

    it 'must handle duplicate svn urls when passed type is svn_sync' do
      repository = create(:svn_repository)
      create(:enlistment, project: Project.find_by(vanity_url: @project_id), repository: repository)

      assert_no_difference ['Repository.count', 'Enlistment.count'] do
        post :create, project_id: @project_id,
                      repository: repository.attributes.merge(type: 'SvnSyncRepository')
      end

      must_redirect_to action: :index
      flash[:notice].must_equal I18n.t('enlistments.create.notice', url: repository.url)
    end

    it 'should avoid duplicate repository when git url passed as https or in ssh format' do
      repository1 = create(:git_repository, url: 'git://github.com/test/repo')
      create(:enlistment, repository: repository1, project: @enlistment.project)

      Repository.any_instance.stubs(:bypass_url_validation).returns(false)
      OhlohScm::Adapters::GitAdapter.any_instance.stubs(:validate_server_connection)

      assert_no_difference ['Repository.count', 'Enlistment.count'] do
        post :create, project_id: @project_id,
                      repository: { url: 'https://github.com/test/repo', type: 'GitRepository' }
      end
      assigns(:project_has_repo_url).must_equal true
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
