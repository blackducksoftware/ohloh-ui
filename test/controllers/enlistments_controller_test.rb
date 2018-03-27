require 'test_helper'

describe 'EnlistmentsControllerTest' do
  before do
    @enlistment = create_enlistment_with_code_location
    @project_id = @enlistment.project.vanity_url
    @account = create(:account)
  end

  describe 'index' do
    it 'should return enlistment record' do
      mock_and_get :index, project_id: @project_id
      must_respond_with :ok
      must_render_template :index
      assigns(:enlistments).count.must_equal 1
      assigns(:enlistments).first.must_equal @enlistment
    end

    it 'should return if valid filter_by query' do
      mock_and_get :index, project_id: @project_id, query: @enlistment.project.name
      must_respond_with :ok
      must_render_template :index
      assigns(:enlistments).count.must_equal 1
      assigns(:enlistments).first.must_equal @enlistment
    end

    it 'should not return if invalid filter query' do
      mock_and_get :index, project_id: @project_id, query: 'Should Fail'
      must_respond_with :ok
      must_render_template :index
      assigns(:enlistments).count.must_equal 0
    end

    it 'should return failed_jobs as true when there failed jobs for the project' do
      mock_and_get :index, project_id: @enlistment.project.id do
        FetchJob.create(code_location_id: @enlistment.code_location_id, status: 3)
      end

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

  describe 'new' do
    it 'must render the new page' do
      login_as @account
      get :new, project_id: @project_id
      must_respond_with :ok
      must_render_template :new
    end

    it 'should disallow non-managers from viewing the page' do
      project = @enlistment.project
      create(:permission, target: project, remainder: true)
      login_as create(:account)
      get :new, project_id: project.vanity_url
      assert_response :unauthorized
    end
  end

  describe 'edit' do
    it 'must render the edit page' do
      login_as @account
      mock_and_get :edit, project_id: @project_id, id: @enlistment.id
      must_respond_with :ok
      must_render_template :edit
    end

    it 'should prevent non-managers from editing' do
      project = @enlistment.project
      create(:permission, target: project, remainder: true)
      login_as create(:account)
      mock_and_get :edit, project_id: project.vanity_url, id: @enlistment.id
      assert_response :unauthorized
    end

    it 'should redirect to index page if the project is invalid' do
      login_as @account
      @enlistment.project.update_attribute(:description, Faker::Lorem.characters(820))
      mock_and_get :edit, project_id: @enlistment.project_id, id: @enlistment.id
      must_redirect_to action: :index
      flash[:error].must_be :present?
    end
  end

  it 'update' do
    login_as @account

    Enlistment.any_instance.stubs(:ensure_forge_and_job)
    Project.any_instance.stubs(:schedule_delayed_analysis)
    put :update, project_id: @project_id, id: @enlistment.id,
                 enlistment: { ignore: 'Ignore Me' }

    must_respond_with :redirect
    must_redirect_to action: :index
    @enlistment.reload.ignore.must_equal 'Ignore Me'
  end

  describe 'destroy' do
    it 'destroy successfully' do
      login_as @account
      Enlistment.any_instance.stubs(:ensure_forge_and_job)
      stub_code_location_subscription_api_call(@enlistment.code_location_id, @enlistment.project_id, 'delete') do
        delete :destroy, id: @enlistment.id, project_id: @project_id
      end
      must_respond_with :redirect
      must_redirect_to action: :index
      @enlistment.reload.deleted.must_equal true
    end

    it 'should redirect to index page if the project is invalid' do
      login_as @account
      @enlistment.project.update_attribute(:description, Faker::Lorem.characters(820))
      delete :destroy, project_id: @enlistment.project.vanity_url, id: @enlistment.id
      must_redirect_to action: :index
      flash[:error].must_be :present?
    end
  end

  describe 'create' do
    before do
      login_as @account
      Sidekiq::Worker.clear_all
    end

    let(:project) { create(:project) }

    it 'must notify errors in github username' do
      stub_github_user_repositories_call do
        username = 'github.com/stan'
        post :create, project_id: project.id, code_location: { scm_type: :GithubUser, url: username }
        assigns(:code_location).errors.messages[:url].first.must_equal I18n.t('invalid_github_username')
        must_render_template :new
      end
    end

    it 'must create enlistments jobs using github username' do
      stub_github_user_repositories_call do
        EnlistmentWorker.jobs.size.must_equal 0
        username = 'stan'
        post :create, project_id: project.to_param, code_location: { scm_type: :GithubUser, url: username }
        must_respond_with :redirect
        must_redirect_to action: :index
        EnlistmentWorker.jobs.size.must_equal 1
      end
    end

    it 'must prevent non-managers from creating enlistments' do
      create(:permission, target: project, remainder: true)
      login_as create(:account)
      post :create, project_id: project.id, code_location: { scm_type: :GithubUser, url: :stan }
      assert_response :unauthorized
    end

    it 'should not create job for a existing github user_name' do
      username = 'stan'
      post :create, project_id: project.to_param, code_location: { scm_type: :GithubUser, url: username }
      EnlistmentWorker.jobs.size.must_equal 1

      post :create, project_id: project.to_param, code_location: { scm_type: :GithubUser, url: username }
      must_redirect_to action: :index
      EnlistmentWorker.jobs.size.must_equal 1
      flash[:error].must_be :present?
    end

    it 'should create repository and enlistments' do
      CodeLocationSubscription.stubs(:code_location_exists?)
      Project.any_instance.stubs(:ensure_job)
      branch_name = 'master'
      url = 'https://github.com/rails/rails'
      assert_difference 'Enlistment.count' do
        WebMocker.create_code_location
        WebMocker.get_project_code_locations
        WebMocker.get_code_location
        post :create, project_id: project.to_param,
                      code_location: { branch: branch_name, url: url, scm_type: 'git' }
      end
      must_respond_with :redirect
      must_redirect_to action: :index
      enlistment = Enlistment.last
      enlistment.code_location.branch.must_equal branch_name
      enlistment.code_location.url.must_equal url.sub('https', 'git')
    end

    it 'wont create duplicate repositories within the same project' do
      code_location = code_location_stub
      CodeLocationSubscription.stubs(:code_location_exists?).returns(true)
      post :create, project_id: project.to_param, code_location: code_location.scm_attributes
      must_redirect_to action: :index
      flash[:notice].must_match 'already exists for this project'
    end

    it 'must show alert message for adding the first enlistment' do
      CodeLocationSubscription.stubs(:code_location_exists?)
      Project.any_instance.stubs(:ensure_job)
      branch_name = 'master'
      url = 'https://github.com/rails/rails'

      Enlistment.any_instance.stubs(:ensure_forge_and_job)
      WebMocker.create_code_location
      post :create, project_id: project.to_param,
                    code_location: { branch: branch_name, url: url, scm_type: 'git' }

      must_redirect_to project_enlistments_path(project)
      flash[:show_first_enlistment_alert].must_be :present?
    end

    it 'must render error for missing url' do
      CodeLocationSubscription.stubs(:code_location_exists?)

      WebMocker.create_code_location_url_failure
      post :create, project_id: project.to_param, code_location: { branch: :branch, scm_type: :git }

      assigns(:code_location).errors[:url].must_be :present?
      must_render_template :new
    end

    describe 'a code_location can be added to multiple projects' do
      describe 'when code_location already exist for a project' do
        it 'should not add the code_location' do
          code_location = CodeLocation.new(url: 'https://github.com/rails/rails', branch: :master, scm_type: :git)
          Enlistment.any_instance.stubs(:ensure_forge_and_job)

          assert_difference 'Enlistment.count' do
            WebMocker.code_location_exists(false)
            WebMocker.create_code_location
            post :create, project_id: project.to_param, code_location: code_location.scm_attributes
          end

          assert_no_difference 'Enlistment.count' do
            WebMocker.code_location_exists(true)
            post :create, project_id: project.to_param, code_location: code_location.scm_attributes
          end

          must_redirect_to action: :index
          flash[:notice].must_match 'already exists for this project'
        end
      end

      describe 'when code_location exist for a different project' do
        it 'should add a enlistment and reuse existing code_location' do
          code_location = CodeLocation.new(url: 'https://github.com/rails/rails', branch: :master, scm_type: :git)
          another_project = create(:project)
          Enlistment.any_instance.stubs(:ensure_forge_and_job)

          assert_difference 'Enlistment.count' do
            WebMocker.code_location_exists(false)
            WebMocker.create_code_location
            post :create, project_id: project.to_param, code_location: code_location.scm_attributes
          end

          assert_difference 'Enlistment.count' do
            WebMocker.code_location_exists(false)
            WebMocker.create_code_location(409) # conflict
            post :create, project_id: another_project.to_param, code_location: code_location.scm_attributes
          end

          project.enlistments.pluck(:code_location_id).must_equal another_project.enlistments.pluck(:code_location_id)
        end
      end
    end
  end

  it 'show must return valid data for xml request' do
    login_as @account
    client_id = create(:api_key).oauth_application.uid

    mock_and_get :show, project_id: @project_id, id: @enlistment.id, format: :xml, api_key: client_id

    must_respond_with :ok
    must_render_template :show
  end
end

def mock_and_get(action, params)
  if action == :index
    Enlistment.connection.execute("insert into repositories (type, url) values ('GitRepository', 'url')")
    repository_id = Enlistment.connection.execute('select max(id) from repositories').values[0][0]
    Enlistment.connection.execute("insert into code_locations (repository_id) values (#{repository_id})")
    code_location_id = Enlistment.connection.execute('select max(id) from code_locations').values[0][0]
    @enlistment.update!(code_location_id: code_location_id)
    Project.any_instance.stubs(:code_locations).returns([])
    yield if block_given?
  end

  WebMocker.get_code_location(@enlistment.code_location_id)
  get action, params
end
