# frozen_string_literal: true

require 'test_helper'

class EnlistmentsControllerTest < ActionController::TestCase
  before do
    @enlistment = create_enlistment_with_code_location
    @project_id = @enlistment.project.vanity_url
    @account = create(:account)
  end

  describe 'index' do
    before { ApiAccess.stubs(:available?).returns(true) }

    it 'should return enlistment record' do
      mock_and_get :index, params: { project_id: @project_id }
      assert_response :ok
      assert_template :index
      _(assigns(:enlistments).count).must_equal 1
      _(assigns(:enlistments).first).must_equal @enlistment
    end

    it 'should return if valid filter_by query' do
      mock_and_get :index, params: { project_id: @project_id, query: @enlistment.project.name }
      assert_response :ok
      assert_template :index
      _(assigns(:enlistments).count).must_equal 1
      _(assigns(:enlistments).first).must_equal @enlistment
    end

    it 'should not return if invalid filter query' do
      mock_and_get :index, params: { project_id: @project_id, query: 'Should Fail' }
      assert_response :ok
      assert_template :index
      _(assigns(:enlistments).count).must_equal 0
    end

    it 'should return a failed job report when there are failed jobs' do
      mock_and_get(:index, true, params: { project_id: @enlistment.project.id }) do
        FetchJob.create(code_location_id: @enlistment.code_location_id, status: 3)
      end

      assert_response :ok
      assert_template :index
      _(assigns(:stale_jobs_report)).wont_be :empty?
      _(response.body).must_match I18n.t('enlistments.index.failure.dnf_present')
    end

    it 'must render page when code_location is null' do
      Enlistment.any_instance.stubs(:code_location).returns(NilCodeLocation.new)

      mock_and_get :index, params: { project_id: @project_id }

      assert_response :ok
    end

    it 'must render projects/deleted when project is deleted' do
      login_as @account
      ApplicationController.any_instance.stubs(:current_user_can_manage?).returns(true)
      project = @enlistment.project
      project.update!(deleted: true, editor_account: @account)

      get :index, params: { project_id: project.id }

      assert_template 'deleted'
    end
  end

  describe 'new' do
    it 'must render the new page' do
      login_as @account
      get :new, params: { project_id: @project_id }
      assert_response :ok
      assert_template :new
    end

    it 'should disallow non-managers from viewing the page' do
      project = @enlistment.project
      create(:permission, target: project, remainder: true)
      login_as create(:account)
      get :new, params: { project_id: project.vanity_url }
      assert_response :unauthorized
    end
  end

  describe 'edit' do
    it 'must render the edit page' do
      login_as @account
      mock_and_get :edit, params: { project_id: @project_id, id: @enlistment.id }
      assert_response :ok
      assert_template :edit
    end

    it 'should prevent non-managers from editing' do
      project = @enlistment.project
      create(:permission, target: project, remainder: true)
      login_as create(:account)
      mock_and_get :edit, params: { project_id: project.vanity_url, id: @enlistment.id }
      assert_response :unauthorized
    end

    it 'should redirect to index page if the project is invalid' do
      login_as @account
      @enlistment.project.update_attribute(:description, Faker::Lorem.characters(number: 820))
      mock_and_get :edit, params: { project_id: @enlistment.project_id, id: @enlistment.id }
      assert_redirected_to action: :index
      _(flash[:error]).must_be :present?
    end
  end

  describe 'edit_allowed_files' do
    it 'must render the edit_allowed_files page' do
      login_as @account
      mock_and_get :edit_allowed_files, params: { project_id: @project_id, id: @enlistment.id }
      assert_response :ok
      assert_template :edit_allowed_files
    end

    it 'should prevent non-managers from editing' do
      project = @enlistment.project
      create(:permission, target: project, remainder: true)
      login_as create(:account)
      mock_and_get :edit_allowed_files, params: { project_id: project.vanity_url, id: @enlistment.id }
      assert_response :unauthorized
    end
  end

  it 'update' do
    login_as @account

    Enlistment.any_instance.stubs(:ensure_forge_and_job)
    Project.any_instance.stubs(:schedule_delayed_analysis)
    put :update, params: { project_id: @project_id, id: @enlistment.id,
                           enlistment: { ignore: 'Ignore Me' } }

    assert_response :redirect
    assert_redirected_to action: :index
    _(@enlistment.reload.ignore).must_equal 'Ignore Me'
  end

  it 'update allowed files' do
    login_as @account

    Enlistment.any_instance.stubs(:ensure_forge_and_job)
    Project.any_instance.stubs(:schedule_delayed_analysis)
    put :update, params: { project_id: @project_id, id: @enlistment.id,
                           enlistment: { allowed_fyles: 'debian' } }

    assert_response :redirect
    assert_redirected_to action: :index
    _(@enlistment.reload.allowed_fyles).must_equal 'debian'
  end

  describe 'destroy' do
    it 'destroy successfully' do
      login_as @account
      Enlistment.any_instance.stubs(:ensure_forge_and_job)
      stub_code_location_subscription_api_call(@enlistment.code_location_id, @enlistment.project_id, 'delete') do
        delete :destroy, params: { id: @enlistment.id, project_id: @project_id }
      end
      assert_response :redirect
      assert_redirected_to action: :index
      _(@enlistment.reload.deleted).must_equal true
    end

    it 'wont delete enlistment when there is an error in fisbot api' do
      login_as @account
      Enlistment.any_instance.stubs(:ensure_forge_and_job)
      error_response = Net::HTTPServerError.new('1.1', '503', 'error')
      error_response.stubs(:body).returns('Api error')
      Net::HTTP.any_instance.stubs(:request).returns(error_response)
      _(-> { delete :destroy, params: { id: @enlistment.id, project_id: @project_id } }).must_raise(StandardError)
      _(@enlistment.reload.deleted).must_equal false
    end

    it 'should redirect to index page if the project is invalid' do
      login_as @account
      @enlistment.project.update_attribute(:description, Faker::Lorem.characters(number: 820))
      delete :destroy, params: { project_id: @enlistment.project.vanity_url, id: @enlistment.id }
      assert_redirected_to action: :index
      _(flash[:error]).must_be :present?
    end
  end

  describe 'create' do
    before do
      login_as @account
      Sidekiq::Worker.clear_all
    end

    let(:project) { create(:project) }

    it 'must notify errors in github username' do
      username = 'github.com/stan'
      post :create, params: { project_id: project.id, code_location: { scm_type: :GithubUser, url: username } }
      _(assigns(:code_location).errors.messages[:url].first).must_equal I18n.t('invalid_github_username')
      assert_template :new
    end

    it 'must create enlistments jobs using github username' do
      _(EnlistmentWorker.jobs.size).must_equal 0
      username = 'stan'
      post :create, params: { project_id: project.to_param, code_location: { scm_type: :GithubUser, url: username } }
      assert_response :redirect
      assert_redirected_to action: :index
      _(EnlistmentWorker.jobs.size).must_equal 1
    end

    it 'must raise error if fisbot api fails' do
      CodeLocationSubscription.stubs(:code_location_exists?)
      Project.any_instance.stubs(:ensure_job)
      url = 'https://github.com/rails/rails'
      error_response = Net::HTTPServerError.new('1.1', '503', 'error')
      error_response.stubs(:body).returns('Api error')
      Net::HTTP.any_instance.stubs(:request).returns(error_response)
      _(lambda do
        assert_no_difference 'Enlistment.count' do
          post :create, params: { project_id: project.to_param,
                                  code_location: { branch: 'master', url: url, scm_type: 'git' } }
        end
      end).must_raise(StandardError)
    end

    it 'must prevent non-managers from creating enlistments' do
      create(:permission, target: project, remainder: true)
      login_as create(:account)
      post :create, params: { project_id: project.id, code_location: { scm_type: :GithubUser, url: :stan } }
      assert_response :unauthorized
    end

    it 'should not create job for a existing github user_name' do
      username = 'stan'
      post :create, params: { project_id: project.to_param, code_location: { scm_type: :GithubUser, url: username } }
      _(EnlistmentWorker.jobs.size).must_equal 1

      post :create, params: { project_id: project.to_param, code_location: { scm_type: :GithubUser, url: username } }
      assert_redirected_to action: :index
      _(EnlistmentWorker.jobs.size).must_equal 1
      _(flash[:error]).must_be :present?
    end

    it 'must create repository subscription and enlistment' do
      ApiAccess.stubs(:available?).returns(true)
      CodeLocationSubscription.stubs(:code_location_exists?)
      Project.any_instance.stubs(:ensure_job)
      branch_name = 'main'
      url = 'https://github.com/rails/rails'
      CodeLocationSubscription.expects(:create)
      assert_difference 'Enlistment.count' do
        WebMocker.create_code_location
        WebMocker.get_project_code_locations
        WebMocker.get_code_location
        post :create, params: { project_id: project.to_param,
                                code_location: { branch: branch_name, url: url, scm_type: 'git' } }
      end
      assert_response :redirect
      assert_redirected_to action: :index
      enlistment = Enlistment.last
      _(enlistment.code_location.branch).must_equal branch_name
      _(enlistment.code_location.url).must_equal url
    end

    it 'wont create duplicate repositories within the same project' do
      @controller.stubs(:get_code_location_id).returns('1')
      code_location = code_location_stub
      CodeLocationSubscription.stubs(:code_location_exists?).returns(true)
      post :create, params: { project_id: project.to_param, code_location: code_location.scm_attributes }
      assert_redirected_to action: :index
      _(flash[:notice]).must_match 'already exists for this project'
    end

    it 'should restore deleted enlistments within the same project' do
      CodeLocationSubscription.stubs(:code_location_exists?)
      WebMocker.create_subscription
      branch_name = 'main'
      url = 'https://github.com/rails/rails'
      post :create,
           params: { project_id: project.to_param, code_location: { branch: branch_name, url: url, scm_type: 'git' } }
      enlistment = Enlistment.last
      enlistment.update_column('deleted', true)
      enlistment.create_edit.update_column('undone', true)

      CodeLocationSubscription.stubs(:code_location_exists?).returns(true)
      CodeLocationApi.any_instance.stubs(:fetch).returns("{\"id\":#{enlistment.code_location_id}}")
      post :create,
           params: { project_id: project.to_param, code_location: { branch: branch_name, url: url, scm_type: 'git' } }

      assert_response :redirect
      assert_redirected_to action: :index
      _(flash[:success]).must_match 'Deleted CodeLocation has been successfully restored.'
    end

    it 'must show alert message for adding the first enlistment' do
      CodeLocationSubscription.stubs(:code_location_exists?)
      Project.any_instance.stubs(:ensure_job)
      branch_name = 'main'
      url = 'https://github.com/rails/rails'

      Enlistment.any_instance.stubs(:ensure_forge_and_job)
      WebMocker.create_code_location
      WebMocker.create_subscription
      post :create, params: { project_id: project.to_param,
                              code_location: { branch: branch_name, url: url, scm_type: 'git' } }

      assert_redirected_to project_enlistments_path(project)
      _(flash[:show_first_enlistment_alert]).must_be :present?
    end

    it 'must render error for missing url' do
      CodeLocationSubscription.stubs(:code_location_exists?)

      WebMocker.create_code_location_url_failure
      post :create, params: { project_id: project.to_param, code_location: { branch: :branch, scm_type: :git } }

      _(assigns(:code_location).errors[:url]).must_be :present?
      assert_template :new
    end

    describe 'a code_location can be added to multiple projects' do
      describe 'when code_location already exist for a project' do
        it 'should not add the code_location' do
          code_location = CodeLocation.new(url: 'https://github.com/rails/rails', branch: :main, scm_type: :git)
          Enlistment.any_instance.stubs(:ensure_forge_and_job)

          assert_difference 'Enlistment.count' do
            WebMocker.code_location_exists(false)
            WebMocker.create_code_location
            WebMocker.create_subscription
            post :create, params: { project_id: project.to_param, code_location: code_location.scm_attributes }
          end

          assert_no_difference 'Enlistment.count' do
            WebMocker.code_location_exists(true)
            @controller.stubs(:get_code_location_id).returns('1')
            post :create, params: { project_id: project.to_param, code_location: code_location.scm_attributes }
          end

          assert_redirected_to action: :index
          _(flash[:notice]).must_match 'already exists for this project'
        end
      end

      describe 'when code_location exist for a different project' do
        it 'should add a enlistment and reuse existing code_location' do
          code_location = CodeLocation.new(url: 'https://github.com/rails/rails', branch: :main, scm_type: :git)
          another_project = create(:project)
          Enlistment.any_instance.stubs(:ensure_forge_and_job)

          assert_difference 'Enlistment.count' do
            WebMocker.code_location_exists(false)
            WebMocker.create_code_location
            WebMocker.create_subscription
            post :create, params: { project_id: project.to_param, code_location: code_location.scm_attributes }
          end

          assert_difference 'Enlistment.count' do
            WebMocker.code_location_exists(false)
            WebMocker.create_code_location(409) # conflict
            WebMocker.create_subscription
            post :create, params: { project_id: another_project.to_param, code_location: code_location.scm_attributes }
          end

          code_location_id = another_project.enlistments.pluck(:code_location_id)
          _(project.enlistments.pluck(:code_location_id)).must_equal code_location_id
        end
      end
    end
  end

  it 'show must return valid data for xml request' do
    login_as @account
    client_id = create(:api_key).oauth_application.uid

    mock_and_get :show, params: { project_id: @project_id, id: @enlistment.id, format: :xml, api_key: client_id }

    assert_response :ok
    assert_template :show
  end
end

# rubocop:disable Style/OptionalArguments
def mock_and_get(action, dnf = false, params)
  if action == :index
    Enlistment.connection.execute("insert into repositories (type, url) values ('GitRepository', 'url')")
    repository_id = Enlistment.connection.execute('select max(id) from repositories').values[0][0]
    Enlistment.connection.execute("insert into code_locations (repository_id,
                                  do_not_fetch) values (#{repository_id}, #{dnf})")
    code_location_id = Enlistment.connection.execute('select max(id) from code_locations').values[0][0]
    @enlistment.update!(code_location_id: code_location_id)
    Project.any_instance.stubs(:code_locations).returns([])
    yield if block_given?
  end

  ApiAccess.stubs(:available?).returns(true)
  WebMocker.get_code_location(@enlistment.code_location_id)
  get action, params
end
# rubocop:enable Style/OptionalArguments
