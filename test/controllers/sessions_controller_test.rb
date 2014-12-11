require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  fixtures :accounts

  # new action
  test 'the new action should render correctly' do
    get :new
    assert_response :ok
  end

  # create action
  test 'create with valid credentials should log in' do
    assert_equal nil, session[:account_id]
    post :create, login: { login: 'admin', password: 'test' }
    assert_response :found
    assert_equal accounts(:admin).id, session[:account_id]
    assert_equal I18n.t('sessions.create.success'), flash[:notice]
  end

  test 'create with invalid credentials should not log in' do
    assert_equal nil, session[:account_id]
    post :create, login: { login: 'admin', password: 'not the password' }
    assert_response :bad_request
    assert_equal nil, session[:account_id]
    assert_equal I18n.t('sessions.create.error'), flash[:error]
  end

  test 'create with valid credentials for disabled accounts should not log in' do
    assert_equal nil, session[:account_id]
    post :create, login: { login: 'sir_spams_a_lot', password: 'test' }
    assert_response :bad_request
    assert_equal nil, session[:account_id]
    assert_equal I18n.t('sessions.create.disabled_error'), flash[:error]
  end

  test 'create with valid credentials for unactivated accounts should not log in' do
    assert_equal nil, session[:account_id]
    post :create, login: { login: 'unactivated', password: 'testy' }
    assert_response :bad_request
    assert_equal nil, session[:account_id]
    assert_equal I18n.t('sessions.create.unactivated_error'), flash[:error]
  end

  test 'create with remember me set should save the right data to the account and cookies' do
    admin = accounts(:admin)
    assert_nil admin.remember_token
    assert_nil admin.remember_token_expires_at
    post :create, login: { login: 'admin', password: 'test', remember_me: '1' }
    assert_response :found
    admin.reload
    assert_not_nil admin.remember_token
    assert_not_nil admin.remember_token_expires_at
    assert_equal admin.remember_token, cookies[:auth_token]
  end

  test 'create should inform uninformed users about privacy' do
    assert_equal nil, session[:account_id]
    post :create, login: { login: 'privacy', password: 'test' }
    assert_response :found
    assert_equal accounts(:not_privacy_informed).id, session[:account_id]
    assert_equal I18n.t('sessions.create.learn_about_privacy'), flash[:notice]
  end

  # destroy action
  test 'destroy should log out' do
    session[:account_id] = accounts(:admin).id
    delete :destroy
    assert_response :found
    assert_equal nil, session[:account_id]
    assert_equal I18n.t('sessions.destroy.success'), flash[:notice]
  end

  test 'destroy should clear remember me data' do
    admin = accounts(:admin)
    admin.remember_me
    session[:account_id] = accounts(:admin).id
    delete :destroy
    assert_response :found
    admin.reload
    assert_nil admin.remember_token
    assert_nil admin.remember_token_expires_at
    assert_equal admin.remember_token, cookies[:auth_token]
  end
end
