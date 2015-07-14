require 'test_helper'

describe 'SessionsControllerTest' do
  let(:admin) { create(:admin, password: 'password', email_opportunities_visited: Date.today) }

  describe 'new' do
    it 'the new action should render correctly' do
      get :new
      must_respond_with :ok
    end
  end

  describe 'create' do
    it 'create with valid credentials should log in' do
      session[:account_id].must_be_nil
      post :create, login: { login: admin.login, password: 'password' }
      must_respond_with :found
      session[:account_id].must_equal admin.id
      flash[:notice].must_equal I18n.t('sessions.create.success')
    end

    it 'create with invalid credentials should not log in' do
      session[:account_id].must_be_nil
      post :create, login: { login: 'admin', password: 'not the password' }
      must_respond_with :bad_request
      session[:account_id].must_be_nil
      flash[:error].must_equal I18n.t('sessions.create.error')
    end

    it 'create with valid credentials for disabled accounts should not log in' do
      create(:spammer, login: 'spammer', password: 'password')
      session[:account_id].must_be_nil
      post :create, login: { login: 'spammer', password: 'password' }
      must_respond_with :bad_request
      session[:account_id].must_be_nil
      flash[:error].must_equal I18n.t('sessions.create.disabled_error')
    end

    it 'create with valid credentials for unactivated accounts should not log in' do
      inactive_account = create(:unactivated, password: 'password')
      session[:account_id].must_be_nil
      post :create, login: { login: inactive_account.login, password: 'password' }
      must_respond_with :bad_request
      session[:account_id].must_be_nil
      flash[:error].must_equal I18n.t('sessions.create.unactivated_error')
    end

    it 'create with remember me set should save the right data to the account and cookies' do
      admin.remember_token.must_be_nil
      admin.remember_token_expires_at.must_be_nil
      post :create, login: { login: admin.login, password: 'password', remember_me: '1' }
      must_respond_with :found
      admin.reload
      admin.remember_token.wont_be_nil
      admin.remember_token_expires_at.wont_be_nil
      cookies[:auth_token].must_equal admin.remember_token
    end

    it 'create should inform uninformed users about privacy' do
      account = create(:account, email_opportunities_visited: nil, password: 'password')
      session[:account_id].must_be_nil
      post :create, login: { login: account.login, password: 'password' }
      must_respond_with :found
      session[:account_id].must_equal account.id
      flash[:notice].must_equal I18n.t('sessions.create.learn_about_privacy')
    end
  end

  describe 'destroy' do
    it 'destroy should log out' do
      session[:account_id] = admin.id
      delete :destroy
      must_respond_with :found
      session[:account_id].must_be_nil
      flash[:notice].must_equal I18n.t('sessions.destroy.success')
    end

    it 'destroy should clear remember me data' do
      Account::Authenticator.remember(admin)
      session[:account_id] = admin.id
      delete :destroy
      must_respond_with :found
      admin.reload
      admin.remember_token.must_be_nil
      admin.remember_token_expires_at.must_be_nil
      cookies[:auth_token].must_equal admin.remember_token
    end
  end
end
