require 'test_helper'

describe 'RegistrationsController' do
  let(:account_attributes) do
    FactoryBot.attributes_for(:account).select do |k, _v|
      %w(login email password).include?(k.to_s)
    end
  end

  let(:account_params) { { account: account_attributes } }

  describe 'generate' do
    it 'must save a valid record' do
      github_login = Faker::Name.first_name
      access_token = Faker::Lorem.word
      session[:auth_params] = {
        github_verification_attributes: { token: access_token, unique_id: github_login }
      }
      session[:account_params] = account_params[:account]

      get :generate

      account = assigns(:account)
      account.login.must_equal account_params[:account][:login]
      account.github_verification.unique_id.must_equal github_login
      account.github_verification.token.must_equal access_token
      session[:auth_params].must_be_nil
      session[:account_params].must_be_nil
      must_redirect_to account
    end

    it 'must render to new account page when invalid github credentials' do
      session[:auth_params] = { github_verification_attributes: { token: nil } }
      session[:account_params] = account_params[:account]

      get :generate

      must_redirect_to new_account_path
      flash[:notice].must_match(/can't be blank/)
    end

    it 'must respond with not found when account or auth params session is missing' do
      get :generate

      must_respond_with :not_found
    end
  end
end
