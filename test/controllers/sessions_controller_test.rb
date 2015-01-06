require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  # new action
  it 'the new action should render correctly' do
    get :new
    must_respond_with :ok
  end

  # create action
  it 'create with valid credentials should log in' do
    session[:account_id].must_be_nil
    post :create, login: { login: 'admin', password: 'test' }
    must_respond_with :found
    session[:account_id].must_equal accounts(:admin).id
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
    session[:account_id].must_be_nil
    post :create, login: { login: 'sir_spams_a_lot', password: 'test' }
    must_respond_with :bad_request
    session[:account_id].must_be_nil
    flash[:error].must_equal I18n.t('sessions.create.disabled_error')
  end

  it 'create with valid credentials for unactivated accounts should not log in' do
    session[:account_id].must_be_nil
    post :create, login: { login: 'unactivated', password: 'testy' }
    must_respond_with :bad_request
    session[:account_id].must_be_nil
    flash[:error].must_equal I18n.t('sessions.create.unactivated_error')
  end

  it 'create with remember me set should save the right data to the account and cookies' do
    admin = accounts(:admin)
    admin.remember_token.must_be_nil
    admin.remember_token_expires_at.must_be_nil
    post :create, login: { login: 'admin', password: 'test', remember_me: '1' }
    must_respond_with :found
    admin.reload
    admin.remember_token.wont_be_nil
    admin.remember_token_expires_at.wont_be_nil
    cookies[:auth_token].must_equal admin.remember_token
  end

  it 'create should inform uninformed users about privacy' do
    session[:account_id].must_be_nil
    post :create, login: { login: 'privacy', password: 'test' }
    must_respond_with :found
    session[:account_id].must_equal accounts(:not_privacy_informed).id
    flash[:notice].must_equal I18n.t('sessions.create.learn_about_privacy')
  end

  # destroy action
  it 'destroy should log out' do
    session[:account_id] = accounts(:admin).id
    delete :destroy
    must_respond_with :found
    session[:account_id].must_be_nil
    flash[:notice].must_equal I18n.t('sessions.destroy.success')
  end

  it 'destroy should clear remember me data' do
    admin = accounts(:admin)
    Account::Authenticator.remember(admin)
    session[:account_id] = accounts(:admin).id
    delete :destroy
    must_respond_with :found
    admin.reload
    admin.remember_token.must_be_nil
    admin.remember_token_expires_at.must_be_nil
    cookies[:auth_token].must_equal admin.remember_token
  end
end
