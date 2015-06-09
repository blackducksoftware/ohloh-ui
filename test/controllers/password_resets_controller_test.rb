require 'test_helper'

describe 'PasswordResetsController' do
  let(:token) { SecureRandom.hex(16) }
  let(:original_password) { Faker::Internet.password  }
  let(:account) do
    create(:account, reset_password_tokens: { token => Time.current + 1.hour },
                     password: original_password, password_confirmation: original_password)
  end

  describe 'new' do
    it 'must respond with success' do
      get :new

      must_respond_with :success
      must_render_template 'password_resets/new'
    end

    it 'must redirect if logged in' do
      login_as create(:account)

      get :new

      must_respond_with :redirect
      flash[:notice].must_match(/already logged in/)
    end
  end

  describe 'create' do
    it 'must validate the presence of email' do
      post :create, password_reset: { email: '' }

      must_render_template 'password_resets/new'
      assigns(:password_reset).errors.messages[:email].first.must_match(/required/i)
    end

    it 'must complain about missing account' do
      post :create, password_reset: { email: 'not_a_valid_email' }

      must_render_template 'password_resets/new'
      assigns(:password_reset).errors.messages[:email].first.must_match(/no account/i)
    end

    it 'must successfully send out an email with reset password link' do
      account = create(:account)

      post :create, password_reset: { email: account.email }

      must_respond_with :redirect
      flash[:success].must_equal I18n.t('password_resets.create.success')
      account.reload
      account.reset_password_tokens.keys.first.must_be :present?
      # FIXME: Uncomment after implementing ActionMailer.reset_password_link
      # ActionMailer::Base.deliveries.last.body.must_match(
      #   /^https:.*\/password_reset\/confirm\?account_id=jason&token=#{token}/)
    end
  end

  describe 'confirm' do
    it 'wont reset password for invalid account' do
      get :confirm, account_id: Faker::Name.name, token: token

      must_respond_with 404
    end

    it 'wont reset password for invalid token' do
      get :confirm, account_id: account.login, token: 'foo'

      must_respond_with 404
    end

    it 'wont allow expired tokens' do
      account.update! reset_password_tokens: { token => Time.current }

      get :confirm, account_id: account.login, token: token

      must_redirect_to new_password_reset_path
      flash[:error].must_match(/has expired/)
    end

    it 'must render the confirmation form correctly' do
      get :confirm, account_id: account.login, token: token

      must_respond_with :success
      must_render_template 'password_resets/confirm'
    end
  end

  describe 'reset' do
    it 'wont allow blank password' do
      patch :reset, account_id: account.login, token: token, account: { password: '' }

      assigns(:account).errors.messages[:password].must_be :present?
      must_render_template :confirm
      Account::Authenticator.new(login: account.login, password: original_password).must_be :authenticated?
    end

    it 'must successfully reset the password and clear the token' do
      password = Faker::Internet.password

      patch :reset, account_id: account.login, token: token,
                    account: { password: password, password_confirmation: password,
                               current_password: original_password, reset_password_tokens: '' }

      flash[:success].must_match(/reset success/)
      must_respond_with :redirect
      Account::Authenticator.new(login: account.login, password: password).must_be :authenticated?
      account.reload
      account.reset_password_tokens.must_be :empty?
    end
  end
end
