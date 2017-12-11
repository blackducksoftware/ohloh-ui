require 'test_helper'

describe 'Accounts::VerificationsController' do
  let(:account) { create(:account) }
  before do
    account.verifications.destroy_all
    login_as account
  end

  describe 'generate' do
    it 'must save a valid record' do
      VCR.use_cassette('GithubVerification') do
        session[:auth_params] = { github_verification_attributes: build(:github_verification).attributes }

        get :generate, account_id: account.id

        must_redirect_to account_path(assigns(:account))
        session[:auth_params].must_be_nil
        assigns(:account).github_verification.must_be :present?
      end
    end

    it 'must redirect to new authentication path when token is nil' do
      session[:auth_params] = { github_verification_attributes: { token: nil } }

      get :generate, account_id: account.id
      must_redirect_to new_authentication_path
      flash[:notice].must_equal "can't be blank"
    end

    it 'must respond with not found when session auth params session is missing' do
      get :generate, account_id: account.id
      must_respond_with :not_found
    end

    it 'must redirect to root_path if account is already verified' do
      Account::Access.any_instance.stubs(:mobile_or_oauth_verified?).returns(true)
      get :generate, account_id: account.id

      must_redirect_to root_path
    end

    it 'must respond with not found if account is non existant' do
      get :generate, account_id: Faker::Lorem.word

      must_respond_with :not_found
    end
  end
end
