require 'test_helper'

describe 'RegistrationsController' do
  let(:account_attributes) do
    FactoryGirl.attributes_for(:account).select do |k, _v|
      %w(login email email_confirmation password password_confirmation).include?(k.to_s)
    end
  end

  let(:account_params) { { account: account_attributes } }

  describe 'new' do
    it 'must build a new account' do
      get :new

      must_respond_with :success
      assigns(:account).must_be_instance_of Account
    end
  end

  describe 'validate' do
    it 'must return errors for invalid email' do
      post :validate, account_params.merge(account: { email: '' })
      assigns(:account).wont_be :valid?
      must_render_template :new
    end

    it 'must render the new template when validations fail' do
      post :validate, account_params.merge(account: { email: '' })
      assigns(:account).wont_be :valid?
      must_render_template :new
    end

    it 'must require login' do
      post :validate, account_params.merge(account: { login: '' })
      assigns(:account).errors.messages[:login].must_be :present?
    end

    it 'must require password' do
      post :validate, account_params.merge(account: { password: '' })
      assigns(:account).errors.messages[:password].must_be :present?
    end

    it 'must require email and email_confirmation' do
      post :validate, account_params.merge(account: { email_confirmation: '', email: '' })
      assigns(:account).errors.messages[:email_confirmation].must_be :present?
    end

    it 'must redirect to verification step when account is valid' do
      post :validate, account_params
      session[:account_params].must_equal account_params[:account].stringify_keys
      must_redirect_to new_authentication_path
    end
  end

  describe 'generate' do
    it 'must save a valid record' do
      stub_twitter_digits_verification
      session[:auth_params] = { twitter_digits_verification_attributes: {
        service_provider_url: Faker::Internet.url, credentials: Faker::Lorem.word } }
      session[:account_params] = account_params[:account]

      get :generate

      account = assigns(:account)
      account.login.must_equal account_params[:account][:login]
      account.twitter_digits_verification.must_be :present?
      session[:auth_params].must_be_nil
      session[:account_params].must_be_nil
      must_redirect_to account
    end

    it 'must render new authentication action when digits credentials are invalid' do
      session[:auth_params] = { twitter_digits_verification_attributes: { service_provider_url: nil,
                                                                          credentials: nil } }
      session[:account_params] = account_params[:account]
      TwitterDigitsVerification.any_instance.stubs(:generate_auth_id)

      get :generate

      must_redirect_to new_authentication_path
      flash[:notice].must_equal "can't be blank"
    end

    it 'must respond with not found when account or auth params session is missing' do
      get :generate

      must_respond_with :not_found
    end
  end
end
