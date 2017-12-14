require 'test_helper'

describe 'AuthenticationsController' do
  let(:account) { create(:account) }
  let(:account_params) do
    FactoryBot.attributes_for(:account).select do |k, _v|
      %w(login email password).include?(k.to_s)
    end
  end

  describe 'new' do
    it 'must redirect to the login page for users who have not logged in' do
      session[:account_params] = nil
      get :new

      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'must render new page correctly for new users' do
      session[:account_params] = account_params

      get :new

      must_respond_with :ok
      assigns(:account).must_be :present?
      assigns(:account).firebase_verification.must_be :present?
    end

    it 'must render new page correctly for logged in users' do
      account.verifications.destroy_all
      login_as account

      get :new

      must_respond_with :ok
      assigns(:account).must_be :present?
      assigns(:account).firebase_verification.must_be :present?
    end

    it 'wont allow access to verified users' do
      login_as account

      get :new

      must_redirect_to root_path
    end
  end

  describe 'github_callback' do
    let(:expected_attributes) { { unique_id: 'notalex', token: 'e068fc1968fakef5c7e7fake6369336fake4bab9' } }

    it 'must set auth_params for existing accounts' do
      VCR.use_cassette('GithubVerification') do
        account.verifications.destroy_all
        login_as account

        get :github_callback, code: Faker::Lorem.word

        must_redirect_to generate_account_verifications_path(account)
        session[:auth_params].must_equal(github_verification_attributes: expected_attributes)
      end
    end

    it 'must set auth params for new accounts' do
      VCR.use_cassette('GithubVerification') do
        session[:account_params] = account_params
        get :github_callback, code: Faker::Lorem.word

        must_redirect_to generate_registrations_path
        session[:auth_params].must_equal(github_verification_attributes: expected_attributes)
      end
    end

    it 'must sign in an existing user through github' do
      github_stub = stub(email: account.email, access_token: Faker::Lorem.word)
      @controller.stubs(:github_api).returns(github_stub)

      get :github_callback, code: Faker::Lorem.word

      must_redirect_to account
      request.env[:clearance].current_user.id.must_equal account.id
    end

    it 'must create a github verification record for a matching unverified account' do
      account.github_verification.destroy
      github_stub = stub(email: account.email, login: account.login, access_token: Faker::Lorem.word)
      @controller.stubs(:github_api).returns(github_stub)

      get :github_callback, code: Faker::Lorem.word

      account.reload
      account.github_verification.token.must_equal github_stub.access_token
      account.github_verification.unique_id.must_equal github_stub.login
    end

    it 'must activate email for a matching github email' do
      account.update! activated_at: nil, activation_code: Faker::Lorem.word
      github_stub = stub(email: account.email, login: account.login, access_token: Faker::Lorem.word)
      @controller.stubs(:github_api).returns(github_stub)

      get :github_callback, code: Faker::Lorem.word

      account.reload
      account.access.activated_at.must_be :present?
      account.access.activation_code.must_be_nil
    end

    it 'must assign a random password and set activated_at for new github user' do
      github_stub = stub(email: Faker::Internet.email, login: Faker::Lorem.word, access_token: Faker::Lorem.word)
      @controller.stubs(:github_api).returns(github_stub)

      get :github_callback, code: Faker::Lorem.word

      session[:account_params][:password].must_be :present?
      session[:account_params][:activated_at].must_be :present?
    end

    it 'must assign a random login when github login already exists' do
      github_stub = stub(email: Faker::Internet.email, login: account.login, access_token: Faker::Lorem.word)
      @controller.stubs(:github_api).returns(github_stub)

      get :github_callback, code: Faker::Lorem.word

      session[:account_params][:login].must_match account.login
      session[:account_params][:login].wont_equal account.login
    end

    it 'must refresh github verification token on every login' do
      new_access_token = Faker::Internet.password
      github_stub = stub(email: account.email, login: account.login, access_token: new_access_token)
      @controller.stubs(:github_api).returns(github_stub)

      get :github_callback, code: Faker::Lorem.word

      account.reload
      account.github_verification.token.must_equal new_access_token
    end
  end

  describe 'firebase_callback' do
    it 'should set auth_params for existing accounts' do
      account.verifications.destroy_all
      login_as account

      auth_params = { 'firebase_verification_attributes' => { 'credentials' => Faker::Lorem.word } }

      get :firebase_callback, account: auth_params

      must_redirect_to generate_account_verifications_path(account)
      session[:auth_params].must_equal(auth_params)
    end

    it 'should set auth params for new accounts' do
      session[:account_params] = account_params
      auth_params = { 'firebase_verification_attributes' => { 'credentials' => Faker::Lorem.word } }

      get :firebase_callback, account: auth_params

      must_redirect_to generate_registrations_path
      session[:auth_params].must_equal(auth_params)
    end
  end
end
