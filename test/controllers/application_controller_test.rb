require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  fixtures :accounts

  setup do
    @controller = TestController.new
  end

  test 'render_404 as html' do
    get :renders_404
    assert_response :not_found
    assert response.body.include? I18n.t(:four_oh_four)
    assert response.headers['Content-Type'].include? 'text/html'
  end

  test 'render_404 as json' do
    get :renders_404, format: 'json'
    assert_response :not_found
    assert response.body.include? I18n.t(:four_oh_four)
    assert response.headers['Content-Type'].include? 'application/json'
  end

  test 'render_404 as xml' do
    get :renders_404, format: 'xml'
    assert_response :not_found
    assert response.body.include? I18n.t(:four_oh_four)
    assert response.headers['Content-Type'].include? 'application/xml'
  end

  test 'error message as html' do
    get :error_with_message
    assert_response :unauthorized
    assert response.body.include? 'test error string'
  end

  test 'error message as json' do
    get :error_with_message, format: 'json'
    assert_response :unauthorized
    assert response.body.include? 'test error string'
  end

  test 'error message as xml' do
    get :error_with_message, format: 'xml'
    assert_response :unauthorized
    assert response.body.include? 'test error string'
  end

  test 'session_required with a current user' do
    login_as accounts(:user)
    get :session_required_action
    assert_response :ok
  end

  test 'session_required without a current user' do
    login_as nil
    get :session_required_action
    assert_response :unauthorized
  end

  test 'admin_session_required with a current admin' do
    login_as accounts(:admin)
    get :admin_session_required_action
    assert_response :ok
  end

  test 'admin_session_required without a current user' do
    login_as nil
    get :admin_session_required_action
    assert_response :unauthorized
  end

  test 'admin_session_required with a current plain user' do
    login_as accounts(:user)
    get :admin_session_required_action
    assert_response :unauthorized
  end

  test 'ParamRecordNotFound exceptions are caught and not passed on as 500s' do
    get :throws_param_record_not_found
    assert_response :not_found
  end
end

class TestController < ApplicationController
  before_filter :session_required, only: :session_required_action
  before_filter :admin_session_required, only: :admin_session_required_action

  def renders_404
    render_404
  end

  def error_with_message
    error(message: 'test error string', status: :unauthorized)
  end

  def session_required_action
    render nothing: true
  end

  def admin_session_required_action
    render nothing: true
  end

  def throws_param_record_not_found
    fail ParamRecordNotFound
  end
end

test_routes = proc do
  get 'test/renders_404' => 'test#renders_404'
  get 'test/error_with_message' => 'test#error_with_message'
  get 'test/session_required_action' => 'test#session_required_action'
  get 'test/admin_session_required_action' => 'test#admin_session_required_action'
  get 'test/throws_param_record_not_found' => 'test#throws_param_record_not_found'
end
Rails.application.routes.eval_block(test_routes)
