# frozen_string_literal: true

require 'test_helper'

describe 'ApplicationController' do
  describe 'TestController' do
    setup do
      @controller = TestController.new
      @controller.request = @request
      @controller.response = @response
    end

    it 'render_404 as html' do
      get :renders_404
      must_respond_with :not_found
      response.body.must_include(I18n.t('application.error.header'))
      response.headers['Content-Type'].must_include('text/html')
    end

    it 'render_404 as json' do
      get :renders_404, format: 'json'
      must_respond_with :not_found
      response.body.must_include(I18n.t(:four_oh_four))
      response.headers['Content-Type'].must_include('text/html')
    end

    it 'render_404 as xml' do
      get :renders_404, format: 'xml'
      must_respond_with :not_found
      response.body.must_include(I18n.t(:four_oh_four))
      response.headers['Content-Type'].must_include('text/html')
    end

    it 'render_404 as png' do
      get :renders_404, format: 'png'
      must_respond_with :not_found
      response.body.blank?.must_equal false
      response.headers['Content-Type'].must_include('text/html')
    end

    it 'render_404 with request of php should respond with html' do
      get :renders_404, format: 'php'
      must_respond_with :not_found
      response.body.must_include(I18n.t('application.error.header'))
      response.headers['Content-Type'].must_include('text/html')
    end

    it 'should render error template' do
      get :error_with_message
      must_respond_with :unauthorized
      must_render_template 'application/error.html'
      assigns(:page_context).must_equal({})
      assert_select('#project_header', 0)
      assert_select('#project_masthead', 0)
      assert_select('#org_icon', 0)
      assert_select('#mini_account_row', 0)
    end

    it 'error message as html' do
      get :error_with_message
      must_respond_with :unauthorized
      response.body.must_include(I18n.t('application.error.header'))
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

    it 'does not invoke airbrake on routing errors' do
      Rails.application.config.stubs(:consider_all_requests_local).returns false
      @controller.expects(:notify_airbrake).never
      get :throws_routing_error
      must_respond_with :not_found
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'does not invoke airbrake on param not found errors' do
      Rails.application.config.stubs(:consider_all_requests_local).returns false
      @controller.expects(:notify_airbrake).never
      get :throws_param_record_not_found
      must_respond_with :not_found
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'does not invoke airbrake on non-existant PNGs' do
      Rails.application.config.stubs(:consider_all_requests_local).returns false
      @controller.expects(:notify_airbrake).never
      get :renders_404, format: 'png'
      must_respond_with :not_found
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'does invoke airbrake on generic errors' do
      Rails.application.config.stubs(:consider_all_requests_local).returns false
      @controller.expects(:notify_airbrake).once
      get :throws_standard_error
      must_respond_with :not_found
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'reports to Datadog on FisbotApiError' do
      Rails.application.config.stubs(:consider_all_requests_local)
      DataDogReport.expects(:error).once
      get :throws_fisbot_api_error
      must_redirect_to session[:return_to]
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'does not invoke airbrake if the user agent string has been set to blank (discount, often buggy bots)' do
      request.env.delete 'HTTP_USER_AGENT'
      Rails.application.config.stubs(:consider_all_requests_local).returns false
      @controller.expects(:notify_airbrake).never
      get :throws_standard_error
      must_respond_with :not_found
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'does not prevent sandard errors from being shown to developers' do
      Rails.application.config.stubs(:consider_all_requests_local).returns true
      @controller.expects(:notify_airbrake).never
      -> { get :throws_standard_error }.must_raise(StandardError)
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'session_required with a current user' do
      login_as create(:account)
      get :session_required_action
      must_respond_with :ok
    end

    it 'session_required without a current user' do
      login_as nil
      get :session_required_action
      must_respond_with :redirect
      must_redirect_to new_session_path
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
      admin = create(:admin, remember_token: 'old-token')
      @request.cookies[:remember_token] = admin.remember_token
      get :session_required_action
      must_respond_with :ok
      @request.env[:clearance].current_user.id.must_equal admin.id
    end

    it 'handles nil page param' do
      @controller.params = { page: nil }
      @controller.page_param.must_equal 1
    end

    it 'handles blank page param' do
      @controller.params = { page: '' }
      @controller.page_param.must_equal 1
    end

    it 'handles garbage page param' do
      @controller.params = { page: 'i_am_a_banana' }
      @controller.page_param.must_equal 1
    end
  end

  describe 'ProjectsController' do
    setup do
      @controller = ProjectsController.new
      @controller.request = @request
      @controller.response = @response
    end

    it 'clears reminders' do
      user = create(:account)
      project = create(:project)
      action = user.actions.create!(status: Action::STATUSES[:remind], stack_project: project)

      login_as user
      get :show, id: create(:project).to_param
      @response.body.must_match(/You can add more projects now./)
      assert_response :success
      action.reload.status.must_equal Action::STATUSES[:remind]

      get :show, id: create(:project).vanity_url, clear_action_reminder: action.id
      @response.body.wont_match(/You can add more projects now./)
      assert_response :success
      action.reload.status.must_equal Action::STATUSES[:completed]
    end

    it 'must redirect spam accounts' do
      account = create(:account)
      login_as account
      account.access.spam!

      get :new

      must_redirect_to new_authentication_path
    end

    it 'must render 404 for MissingTemplate' do
      Rails.application.config.stubs(:consider_all_requests_local)
      get :show, id: create(:project).to_param, format: :rss
      must_respond_with :not_found
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    describe '#update_last_seen_at_and_ip' do
      let(:time_now) { Time.current }
      let(:account) { create(:account, last_seen_at: time_now) }
      let(:ip) { '1.1.1.1' }
      it 'should update last seen at and ip address when user logged in' do
        login_as account
        account.last_seen_ip.must_be_nil
        account.last_seen_at.must_equal time_now
        get :new
        account.reload.last_seen_at.to_i.must_be_within_epsilon (time_now + 1).to_i, Time.now.to_i
        account.last_seen_ip.must_equal '0.0.0.0'
      end

      it 'should not update last seen at and ip when user not logged in' do
        account.last_seen_ip.must_be_nil
        account.last_seen_at.must_equal time_now
        get :index
        account.reload.last_seen_ip.must_be_nil
        account.reload.last_seen_at.to_i.must_equal time_now.to_i
      end

      it 'should pick right ip addr' do
        login_as account
        ip = '192.168.0.1'
        ActionDispatch::Request.any_instance.stubs(:remote_ip).returns(ip)
        get :index
        account.reload.last_seen_ip.must_equal ip
      end
    end
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
    raise ParamRecordNotFound
  end

  def throws_routing_error
    raise ActionController::RoutingError, 'i_am_a_banana'
  end

  def throws_standard_error
    raise StandardError
  end

  def throws_fisbot_api_error
    raise FisbotApiError
  end
end

test_routes = proc do
  get 'test/renders_404' => 'test#renders_404'
  get 'test/error_with_message' => 'test#error_with_message'
  get 'test/session_required_action' => 'test#session_required_action'
  get 'test/admin_session_required_action' => 'test#admin_session_required_action'
  get 'test/throws_param_record_not_found' => 'test#throws_param_record_not_found'
  get 'test/throws_routing_error' => 'test#throws_routing_error'
  get 'test/throws_standard_error' => 'test#throws_standard_error'
  get 'test/throws_fisbot_api_error' => 'test#throws_fisbot_api_error'
end
Rails.application.routes.send(:eval_block, test_routes)
