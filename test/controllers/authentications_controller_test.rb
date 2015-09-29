require 'test_helper'

describe 'AuthenticationsController' do
  let(:account) { create(:account) }
  let(:account_params) do
    FactoryGirl.attributes_for(:account).select do |k, _v|
      %w(login email email_confirmation password password_confirmation).include?(k.to_s)
    end
  end

  describe 'new' do
    it 'must render not_found when account_params is missing' do
    end

    it 'must render new page correctly for new users' do
      session[:account_params] = account_params

      get :new

      must_respond_with :ok
      assigns(:account).must_be :present?
      assigns(:account).twitter_digits_verification.must_be :present?
    end

    it 'must render new page correctly for logged in users' do
      account.verifications.destroy_all
      login_as account

      get :new

      must_respond_with :ok
      assigns(:account).must_be :present?
      assigns(:account).twitter_digits_verification.must_be :present?
    end

    it 'wont allow access to verified users' do
      login_as account

      get :new

      must_redirect_to root_path
    end
  end

  describe 'github_callback' do
    it 'must set auth_params for existing accounts' do
      account.verifications.destroy_all
      login_as account
      code = Faker::Lorem.word

      get :github_callback, code: code

      must_redirect_to generate_account_verifications_path(account)
      session[:auth_params].must_equal(github_verification_attributes: { code: code })
    end

    it 'must set auth params for new accounts' do
      session[:account_params] = account_params
      code = Faker::Lorem.word

      get :github_callback, code: code

      must_redirect_to generate_registrations_path
      session[:auth_params].must_equal(github_verification_attributes: { code: code })
    end
  end

  describe 'digits_callback' do
    it 'should set auth_params for existing accounts' do
      account.verifications.destroy_all
      login_as account

      auth_params = { 'twitter_digits_verification_attributes' => { 'service_provider_url' => Faker::Internet.url,
                                                                    'credentials' => Faker::Lorem.word } }

      get :digits_callback, account: auth_params

      must_redirect_to generate_account_verifications_path(account)
      session[:auth_params].must_equal(auth_params)
    end

    it 'should set auth params for new accounts' do
      session[:account_params] = account_params
      auth_params = { 'twitter_digits_verification_attributes' => { 'service_provider_url' => Faker::Internet.url,
                                                                    'credentials' => Faker::Lorem.word } }

      get :digits_callback, account: auth_params

      must_redirect_to generate_registrations_path
      session[:auth_params].must_equal(auth_params)
    end
  end
end
