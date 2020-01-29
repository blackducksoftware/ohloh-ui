# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/commits_by_project_data'
require 'test_helpers/commits_by_language_data'

describe 'AccountsController' do
  let(:start_date) { (Date.current - 6.years).beginning_of_month }
  let(:admin) { create(:admin) }
  let(:account_attributes) do
    FactoryBot.attributes_for(:account).select do |k, _v|
      %w[login email password].include?(k.to_s)
    end
  end

  let(:account_params) { { account: account_attributes } }

  describe 'new' do
    it 'must build a new account' do
      get :new

      must_respond_with :success
      assigns(:account).must_be_instance_of Account
    end

    it 'must redirect to accounts show page if logged in' do
      account = create(:account)

      login_as account
      get :new

      must_respond_with :redirect
      must_redirect_to account_path(account)
    end
  end

  describe 'create' do
    it 'must return errors for invalid email' do
      post :create, account_params.merge(account: { email: '' })
      assigns(:account).wont_be :valid?
      must_render_template :new
    end

    it 'must render the new template when validations fail' do
      post :create, account_params.merge(account: { email: '' })

      assigns(:account).wont_be :valid?
      must_render_template :new
    end

    it 'must require login' do
      post :create, account_params.merge(account: { login: '' })
      assigns(:account).errors.messages[:login].must_be :present?
    end

    it 'must require password' do
      post :create, account_params.merge(account: { password: '' })
      assigns(:account).errors.messages[:password].must_be :present?
    end

    it 'must require email' do
      post :create, account_params.merge(account: { email: '' })
      assigns(:account).errors.messages[:email].must_be :present?
    end

    it 'must redirect to accounts page after create' do
      post :create, account_params

      must_redirect_to Account.last
    end

    it 'must return error when phone number is a duplicate' do
      existing_account = create(:account)
      firebase_token = [{ 'user_id' => Faker::Internet.password }]
      FirebaseService.any_instance.stubs(:decode).returns(firebase_token)
      create(:firebase_verification, account: existing_account)

      params = account_params[:account].merge(firebase_verification_attributes: { credentials: Faker::Lorem.word })
      post :create, account: params

      assigns(:account).wont_be :valid?
      assigns(:account).errors['firebase_verification.unique_id'].must_be :present?
    end
  end

  describe 'index' do
    it 'should return claimed persons with their cbp_map and positions_map' do
      create_account_with_commits_by_project

      get :index

      must_respond_with :ok
      assigns(:positions_map).length.must_equal 2
      assigns(:people).length.must_equal 10
      assigns(:cbp_map).length.must_equal 10
    end

    it 'should support being queried via the api' do
      key = create(:api_key, account_id: create(:account).id)
      get :index, format: :xml, api_key: key.oauth_application.uid
      must_respond_with :ok
    end
  end

  describe 'show' do
    it 'should set the account and logos' do
      get :show, id: admin.login

      must_respond_with :ok
      assigns(:account).must_equal admin
      assigns(:logos).must_be_empty
    end

    it 'should support being queried via the api' do
      key = create(:api_key, account_id: create(:account).id)
      get :show, id: admin.login, format: :xml, api_key: key.oauth_application.uid
      must_respond_with :ok
    end

    it 'should show error messages being queried without API key' do
      get :show, id: admin.login, format: :xml
      must_respond_with :bad_request
    end

    it 'should show error messages being queried with Invalid API key' do
      get :show, id: admin.login, format: :xml, api_key: 'inavlid_key'
      must_respond_with :bad_request
    end

    it 'should show the account queried via email MD5 and a valid API key' do
      account = create(:account)
      key = create(:api_key, account_id: account.id)
      get :show, id: account.email_md5, format: :xml, api_key: key.oauth_application.uid
      must_respond_with :ok
    end

    it 'should support accounts with account_analyses' do
      best_account_analysis = create(:best_account_analysis)
      key = create(:api_key, account_id: create(:account).id)
      get :show, id: best_account_analysis.account.to_param, format: :xml, api_key: key.oauth_application.uid
      must_respond_with :ok
    end

    it 'should respond to json format' do
      get :show, id: admin.login, format: 'json'

      must_respond_with :ok
      assigns(:account).must_equal admin
    end

    it 'should have view jobs link if current user is admin' do
      login_as admin
      get :show, id: admin.login
      must_select "a[href='/admin/accounts/#{admin.login}/account_analysis_jobs']", true
    end

    it 'should have no view jobs link if current user is not admin' do
      account = create(:account)
      login_as account
      get :show, id: account.login
      must_select "a[href='/admin/accounts/#{account.login}/account_analysis_jobs']", false
    end
  end

  describe 'redirect_if_disabled' do
    it 'must redirect active user trying to access disabled account' do
      account = create(:account)
      login_as create(:account)
      account.access.spam!

      get :show, id: account.login

      must_redirect_to disabled_account_url(account)
      @controller.current_user.wont_be_nil
    end

    it 'must sign out and redirect if current account is disabled' do
      login_as admin
      Account::Access.any_instance.stubs(:disabled?).returns(true)

      get :show, id: admin.login

      must_redirect_to disabled_account_url(admin)
      @controller.current_user.must_be_nil
    end

    it 'should redirect json requests if account is disabled' do
      login_as admin
      Account::Access.any_instance.stubs(:disabled?).returns(true)

      get :show, id: admin.login, format: :json
      must_redirect_to disabled_account_url(admin)
    end

    it 'should redirect if account is labeled a spammer' do
      account = create(:account)
      login_as account
      account.access.spam!
      account.level.must_equal Account::Access::SPAM
      get :show, id: account.id
      must_redirect_to disabled_account_url(account)
    end
  end

  describe 'me' do
    it 'should redirect_to sign in page for unlogged users' do
      get :show, id: 'me'
      must_redirect_to new_session_path
    end

    it 'should render current_users account page for logged users' do
      account = create(:account)
      login_as account
      get :show, id: 'me'
      assigns(:account).must_equal account
      must_respond_with :ok
    end
  end

  describe 'unsubscribe_emails' do
    it 'a valid key for a account should unsubscribe the user' do
      key = Ohloh::Cipher.encrypt(create(:account).id.to_s)
      get :unsubscribe_emails, key: CGI.unescape(key)
      must_respond_with :ok
      assigns(:account).email_master.must_equal false
    end
  end

  describe 'disabled' do
    it 'must respond with success when queried via html' do
      get :disabled, id: create(:spammer).to_param
      must_respond_with :success
    end

    it 'must respond with success when queried via json' do
      get :disabled, id: create(:spammer).to_param, format: :json
      must_respond_with :success
    end
  end

  describe 'edit' do
    it 'must redirect to verification page when not verified' do
      account = create(:account)
      account.verifications.destroy_all
      login_as account

      get :edit, id: account.id

      must_redirect_to new_authentication_path
    end

    it 'must redirect to email activation page when not activated' do
      account = create(:account)
      account.update!(activated_at: nil)
      login_as account

      get :edit, id: account.id

      must_redirect_to new_activation_resend_path
    end

    it 'must respond with unauthorized when account does not exist' do
      get :edit, id: :anything
      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'must respond with success' do
      account = create(:account)
      login_as account
      get :edit, id: account.to_param
      must_render_template 'edit'
      must_respond_with :success
    end

    it 'must redirect to new_session if account is not owned' do
      account = create(:account)
      login_as account
      get :edit, id: create(:account).id
      must_redirect_to new_session_path
    end

    it 'must render the edit page if admin' do
      account = create(:account)
      login_as admin
      get :edit, id: account.id
      must_respond_with :success
    end

    it 'must logout spammer trying to edit or update' do
      account = create(:account)
      login_as account
      cookies[:remember_token] = account.remember_token
      account.access.spam!

      get :edit, id: account.to_param
      must_respond_with :redirect
      must_redirect_to disabled_account_url(account.to_param)
      @request.env[:clearance].current_user.must_be_nil
      cookies[:remember_token].must_be_nil
    end
  end

  describe 'update' do
    let(:account) { create(:account) }
    before { login_as account }

    it 'must fail for invalid data' do
      url = :not_an_url
      post :update, id: account, account: { url: url }
      must_render_template 'edit'
      account.reload.url.wont_equal url
    end

    it 'must display description after a validation error' do
      text = 'about raw content'
      post :update, id: account.to_param, account: { email: '', about_raw: text }

      must_select 'textarea.edit-description', text: text
    end

    it 'must not allow description beyond 500 characters' do
      post :update, id: account.to_param, account: { about_raw: 'a' * 501 }

      assigns(:account).wont_be_nil
      assigns(:account).errors.wont_be_nil
      assigns(:account).errors.messages[:'markup.raw'].must_be :present?
      must_select "p.error[rel='markup.raw']", text: 'is too long (maximum is 500 characters)'
    end

    it 'must accept description within 500 characters' do
      post :update, id: account.to_param, account: {
        about_raw: 'a' * 99 + "\n" + 'a' * 99 + "\r" + 'a' * 300
      }
      must_redirect_to account
    end

    it 'must be successful' do
      location = 'Washington'
      post :update, id: account.to_param, account: { location: location }
      flash[:notice].must_equal 'Save successful!'
      account.reload.location.must_equal location
    end

    it 'must not allow updating other user\'s account' do
      post :update, id: create(:account).id, account: { location: :Wherever }
      must_redirect_to new_session_path
      flash.now[:error].must_match(/You can't edit another's account/)
    end
  end

  describe 'destroy' do
    it 'must allow deletion' do
      AnonymousAccount.create!
      account = create(:account)
      login_as account

      assert_difference 'Account.count', -1 do
        post :destroy, id: account.to_param
        must_redirect_to edit_deleted_account_path(account.login)
      end
    end

    it 'must not allow deletion by other accounts' do
      my_account = create(:account)
      your_account = create(:account)
      login_as my_account

      assert_no_difference 'Account.count' do
        post :destroy, id: your_account.to_param
      end
      must_redirect_to edit_deleted_account_path(your_account)
    end

    it 'while deleting an account, edits.account_id and edits.undone_by should be marked with Anonymous Coward ID' do
      project = create(:project)
      account = create(:account)
      login_as account
      anonymous_account_id = Account.find_or_create_anonymous_account.id
      Edit.delete_all

      manage = project.manages.create!(account: account)
      manage.update!(approved_by: account.id)
      project.update!(best_analysis_id: nil, editor_account: account)

      project.edits.first.account_id.must_equal account.id
      assert_nil project.edits.first.undone_by

      post :destroy, id: account.to_param

      project.edits.first.account_id.must_equal anonymous_account_id
    end

    it 'when deleting an account set the approved_by and deleted_by fields to Anonymous Coward ID' do
      project = create(:project)
      account = create(:account)
      login_as account
      Edit.delete_all

      manage = project.manages.create!(account: account)
      manage.update!(approved_by: account.id)
      project.update!(best_analysis_id: nil, editor_account: account)

      project.manages.wont_be :empty?

      post :destroy, id: account.to_param

      project.reload.manages.must_be :empty?
    end
  end

  describe 'settings' do
    it 'should render settings' do
      get :settings, id: create(:account).id
    end
  end
end
