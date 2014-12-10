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

  # destroy action
  test 'destroy should log out' do
    session[:account_id] = accounts(:admin).id
    delete :destroy
    assert_response :found
    assert_equal nil, session[:account_id]
    assert_equal I18n.t('sessions.destroy.success'), flash[:notice]
  end
end
