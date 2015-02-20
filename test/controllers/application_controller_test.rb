require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  setup do
    @controller = TestController.new
    @controller.request = @request
    @controller.response = @response
  end

  it 'render_404 as html' do
    get :renders_404
    must_respond_with :not_found
    response.body.must_include(I18n.t(:four_oh_four))
    response.headers['Content-Type'].must_include('text/html')
  end

  it 'render_404 as json' do
    get :renders_404, format: 'json'
    must_respond_with :not_found
    response.body.must_include(I18n.t(:four_oh_four))
    response.headers['Content-Type'].must_include('application/json')
  end

  it 'render_404 as xml' do
    get :renders_404, format: 'xml'
    must_respond_with :not_found
    response.body.must_include(I18n.t(:four_oh_four))
    response.headers['Content-Type'].must_include('application/xml')
  end

  it 'error message as html' do
    get :error_with_message
    must_respond_with :unauthorized
    response.body.must_include('test error string')
  end

  it 'error message as json' do
    get :error_with_message, format: 'json'
    must_respond_with :unauthorized
    response.body.must_include('test error string')
  end

  it 'error message as xml' do
    get :error_with_message, format: 'xml'
    must_respond_with :unauthorized
    response.body.must_include('test error string')
  end

  it 'session_required with a current user' do
    login_as create(:account)
    get :session_required_action
    must_respond_with :ok
  end

  it 'session_required without a current user' do
    login_as nil
    get :session_required_action
    must_respond_with :unauthorized
  end

  it 'admin_session_required with a current admin' do
    login_as create(:admin)
    get :admin_session_required_action
    must_respond_with :ok
  end

  it 'admin_session_required without a current user' do
    login_as nil
    get :admin_session_required_action
    must_respond_with :unauthorized
  end

  it 'admin_session_required with a current plain user' do
    login_as create(:account)
    get :admin_session_required_action
    must_respond_with :unauthorized
  end

  it 'ParamRecordNotFound exceptions are caught and not passed on as 500s' do
    get :throws_param_record_not_found
    must_respond_with :not_found
  end

  it 'remember me functionality automatically logs users in' do
    login_as nil
    admin = create(:admin)
    Account::Authenticator.remember(admin)
    @request.cookies[:auth_token] = admin.remember_token
    get :session_required_action
    must_respond_with :ok
    session[:account_id].must_equal admin.id
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
Rails.application.routes.send(:eval_block, test_routes)
