# frozen_string_literal: true

require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  describe 'TestController' do
    before do
      @controller = TestController.new
      @controller.request = @request
      @controller.response = @response
    end

    it 'render_404 as html' do
      get :renders_404
      assert_response :not_found
      _(response.body).must_include(I18n.t('application.error.header'))
      _(response.headers['Content-Type']).must_include('text/html')
    end

    it 'render_404 as json' do
      get :renders_404, format: 'json'
      assert_response :not_found
      _(response.body).must_include(I18n.t(:four_oh_four))
      _(response.headers['Content-Type']).must_include('text/html')
    end

    it 'render_404 as xml' do
      get :renders_404, format: 'xml'
      assert_response :not_found
      _(response.body).must_include(I18n.t(:four_oh_four))
      _(response.headers['Content-Type']).must_include('text/html')
    end

    it 'render_404 as png' do
      get :renders_404, format: 'png'
      assert_response :not_found
      _(response.body.blank?).must_equal false
      _(response.headers['Content-Type']).must_include('text/html')
    end

    it 'render_404 with request of php should respond with html' do
      get :renders_404, format: 'php'
      assert_response :not_found
      _(response.body).must_include(I18n.t('application.error.header'))
      _(response.headers['Content-Type']).must_include('text/html')
    end

    it 'should render error template' do
      get :error_with_message
      assert_response :unauthorized
      assert_template 'application/error'
      _(assigns(:page_context)).must_equal({})
      assert_select('#project_header', 0)
      assert_select('#project_masthead', 0)
      assert_select('#org_icon', 0)
      assert_select('#mini_account_row', 0)
    end

    it 'error message as html' do
      get :error_with_message
      assert_response :unauthorized
      _(response.body).must_include(I18n.t('application.error.header'))
    end

    it 'error message as json' do
      get :error_with_message, format: 'json'
      assert_response :unauthorized
      _(response.body).must_include('test error string')
    end

    it 'error message as xml' do
      get :error_with_message, format: 'xml'
      assert_response :unauthorized
      _(response.body).must_include('test error string')
    end

    it 'does not invoke airbrake on routing errors' do
      Rails.application.config.stubs(:consider_all_requests_local).returns false
      @controller.expects(:notify_airbrake).never
      get :throws_routing_error
      assert_response :not_found
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'does not invoke airbrake on param not found errors' do
      Rails.application.config.stubs(:consider_all_requests_local).returns false
      @controller.expects(:notify_airbrake).never
      get :throws_param_record_not_found
      assert_response :not_found
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'does not invoke airbrake on non-existant PNGs' do
      Rails.application.config.stubs(:consider_all_requests_local).returns false
      @controller.expects(:notify_airbrake).never
      get :renders_404, format: 'png'
      assert_response :not_found
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'does invoke airbrake on generic errors' do
      Rails.application.config.stubs(:consider_all_requests_local).returns false
      @controller.expects(:notify_airbrake).once
      get :throws_standard_error
      assert_response :not_found
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'reports to AppLogger on FisbotApiError' do
      Rails.application.config.stubs(:consider_all_requests_local)
      AppLogger.expects(:error).once
      get :throws_fisbot_api_error
      assert_redirected_to session[:return_to]
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'does not invoke airbrake if the user agent string has been set to blank (discount, often buggy bots)' do
      request.env.delete 'HTTP_USER_AGENT'
      Rails.application.config.stubs(:consider_all_requests_local).returns false
      @controller.expects(:notify_airbrake).never
      get :throws_standard_error
      assert_response :not_found
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'does not prevent sandard errors from being shown to developers' do
      Rails.application.config.stubs(:consider_all_requests_local).returns true
      @controller.expects(:notify_airbrake).never
      _(-> { get :throws_standard_error }).must_raise(StandardError)
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'session_required with a current user' do
      login_as create(:account)
      get :session_required_action
      assert_response :ok
    end

    it 'session_required without a current user' do
      login_as nil
      get :session_required_action
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'admin_session_required with a current admin' do
      login_as create(:admin)
      get :admin_session_required_action
      assert_response :ok
    end

    it 'admin_session_required without a current user' do
      login_as nil
      get :admin_session_required_action
      assert_response :unauthorized
    end

    it 'admin_session_required with a current plain user' do
      login_as create(:account)
      get :admin_session_required_action
      assert_response :unauthorized
    end

    it 'ParamRecordNotFound exceptions are caught and not passed on as 500s' do
      get :throws_param_record_not_found
      assert_response :not_found
    end

    it 'remember me functionality automatically logs users in' do
      skip('FIXME: cookie set from here is not visible in Clearance/session#current_user')
      login_as nil
      admin = create(:admin, remember_token: 'old-token')
      # @request.cookies[:remember_token] = admin.remember_token
      cookies['remember_token'] = admin.remember_token
      get :session_required_action
      assert_response :ok
      _(@controller.current_user.id).must_equal admin.id
      # _(@request.env[:clearance].current_user.id).must_equal admin.id
    end

    it 'handles nil page param' do
      @controller.params = { page: nil }
      _(@controller.page_param).must_equal 1
    end

    it 'handles blank page param' do
      @controller.params = { page: '' }
      _(@controller.page_param).must_equal 1
    end

    it 'handles garbage page param' do
      @controller.params = { page: 'i_am_a_banana' }
      _(@controller.page_param).must_equal 1
    end

    it 'raise_not_found! raises ActionController::RoutingError with unmatched_route param' do
      @controller.params = { unmatched_route: 'missing/path/here' }

      error = assert_raises(ActionController::RoutingError) do
        @controller.raise_not_found!
      end

      _(error.message).must_equal 'No route matches missing/path/here'
    end

    it 'raise_not_found! raises ActionController::RoutingError with nil unmatched_route param' do
      @controller.params = { unmatched_route: nil }

      error = assert_raises(ActionController::RoutingError) do
        @controller.raise_not_found!
      end

      _(error.message).must_equal 'No route matches '
    end

    it 'rescue_from exception raises if consider_all_requests_local is true' do
      Rails.application.config.stubs(:consider_all_requests_local).returns(true)

      assert_raises(StandardError) do
        get :throws_standard_error
      end

      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'rescue_from exception calls render_404 if consider_all_requests_local is false' do
      Rails.application.config.stubs(:consider_all_requests_local).returns(false)
      @controller.expects(:notify_airbrake).once

      get :throws_standard_error
      assert_response :not_found

      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'rescue_from ActionView::MissingTemplate raises if consider_all_requests_local is true' do
      Rails.application.config.stubs(:consider_all_requests_local).returns(true)

      assert_raises(ActionView::MissingTemplate) do
        get :throws_missing_template
      end

      Rails.application.config.unstub(:consider_all_requests_local)
    end

    it 'rescue_from ActionView::MissingTemplate calls render_404 if consider_all_requests_local is false' do
      Rails.application.config.stubs(:consider_all_requests_local).returns(false)

      get :throws_missing_template
      assert_response :not_found

      Rails.application.config.unstub(:consider_all_requests_local)
    end
  end
  describe 'API credential helpers' do
    before do
      @controller = TestController.new
      @controller.request = @request
      @controller.response = @response
    end

    describe '#api_key_from_request' do
      it 'extracts api key from Authorization Bearer header' do
        request.headers['Authorization'] = 'Bearer my-header-key'
        _(@controller.send(:api_key_from_request)).must_equal 'my-header-key'
      end

      it 'falls back to params[:api_key] when no Authorization header' do
        @controller.params = ActionController::Parameters.new(api_key: 'param-key')
        _(@controller.send(:api_key_from_request)).must_equal 'param-key'
      end

      it 'returns nil when neither header nor param is present' do
        _(@controller.send(:api_key_from_request)).must_be_nil
      end

      it 'ignores Authorization header that is not Bearer' do
        request.headers['Authorization'] = 'Basic dXNlcjpwYXNz'
        _(@controller.send(:api_key_from_request)).must_be_nil
      end
    end

    describe '#api_client_id' do
      it 'returns api_key_from_request when present' do
        request.headers['Authorization'] = 'Bearer bearer-key'
        _(@controller.send(:api_client_id)).must_equal 'bearer-key'
      end

      it 'returns doorkeeper application uid when api_key_from_request is blank' do
        mock_app = mock
        mock_app.stubs(:uid).returns('doorkeeper-uid-123')
        mock_token = mock
        mock_token.stubs(:application).returns(mock_app)
        @controller.stubs(:doorkeeper_token).returns(mock_token)
        _(@controller.send(:api_client_id)).must_equal 'doorkeeper-uid-123'
      end

      it 'returns nil when no credentials present' do
        @controller.stubs(:doorkeeper_token).returns(nil)
        _(@controller.send(:api_client_id)).must_be_nil
      end
    end

    describe '#verify_api_access_for_xml_request' do
      it 'returns missing api key for xml request without any credentials' do
        @controller.stubs(:request_format).returns('xml')
        @controller.stubs(:api_client_id).returns(nil)
        @controller.expects(:render_missing_api_key).once
        @controller.send(:verify_api_access_for_xml_request)
      end

      it 'proceeds for xml request with Bearer header credential' do
        @controller.stubs(:request_format).returns('xml')
        request.headers['Authorization'] = 'Bearer valid-key'
        @controller.stubs(:api_client_id).returns('valid-key')
        @controller.expects(:verify_api_key_standing).once
        @controller.expects(:render_missing_api_key).never
        @controller.send(:verify_api_access_for_xml_request)
      end

      it 'proceeds for xml request with doorkeeper OAuth token' do
        @controller.stubs(:request_format).returns('xml')
        @controller.stubs(:api_client_id).returns('doorkeeper-app-uid')
        @controller.expects(:verify_api_key_standing).once
        @controller.expects(:render_missing_api_key).never
        @controller.send(:verify_api_access_for_xml_request)
      end

      it 'skips check entirely for non-xml/json similar requests' do
        @controller.stubs(:request_format).returns('html')
        @controller.expects(:render_missing_api_key).never
        @controller.expects(:verify_api_key_standing).never
        @controller.send(:verify_api_access_for_xml_request)
      end
    end
  end
  describe 'ProjectsController' do
    before do
      @controller = ProjectsController.new
      @controller.request = @request
      @controller.response = @response
    end

    it 'clears reminders' do
      user = create(:account)
      project = create(:project)
      action = user.actions.create!(status: Action::STATUSES[:remind], stack_project: project)

      login_as user
      get :show, params: { id: create(:project).to_param }
      _(@response.body).must_match(/You can add more projects now./)
      assert_response :success
      _(action.reload.status).must_equal Action::STATUSES[:remind]

      get :show, params: { id: create(:project).vanity_url, clear_action_reminder: action.id }
      _(@response.body).wont_match(/You can add more projects now./)
      assert_response :success
      _(action.reload.status).must_equal Action::STATUSES[:completed]
    end

    it 'must redirect spam accounts' do
      account = create(:account)
      login_as account
      account.access.spam!

      get :new

      assert_redirected_to new_authentication_path
    end

    it 'must render 404 for MissingTemplate' do
      Rails.application.config.stubs(:consider_all_requests_local)
      get :show, params: { id: create(:project).to_param }, format: :rss
      assert_response :not_found
      Rails.application.config.unstub(:consider_all_requests_local)
    end

    describe '#update_last_seen_at_and_ip' do
      let(:time_now) { Time.current }
      let(:account) { create(:account, last_seen_at: time_now) }
      let(:ip) { '1.1.1.1' }

      it 'should update last seen at and ip address when user logged in' do
        ApiAccess.stubs(:available?).returns(true)
        login_as account
        _(account.last_seen_ip).must_be_nil
        _(account.last_seen_at).must_equal time_now
        get :new
        _(account.reload.last_seen_at.to_i).must_be_within_epsilon (time_now + 1).to_i, Time.now.to_i
        _(account.last_seen_ip).must_equal '0.0.0.0'
      end

      it 'should not update last seen at and ip when user not logged in' do
        _(account.last_seen_ip).must_be_nil
        _(account.last_seen_at).must_equal time_now
        get :index
        _(account.reload.last_seen_ip).must_be_nil
        _(account.reload.last_seen_at.to_i).must_equal time_now.to_i
      end

      it 'should pick right ip addr' do
        login_as account
        ip = '192.168.0.1'
        ActionDispatch::Request.any_instance.stubs(:remote_ip).returns(ip)
        get :index
        _(account.reload.last_seen_ip).must_equal ip
      end
    end

    describe 'current_project method' do
      it 'returns project when found by id param' do
        project = create(:project)
        get :show, params: { id: project.to_param }
        _(@controller.send(:current_project)).must_equal project
      end

      it 'returns project when not found by id param' do
        assert_raises(ParamRecordNotFound) do
          @controller.params = { project_id: 99_999 }
          @controller.send(:current_project)
        end
      end

      it 'memoizes the project instance variable' do
        project = create(:project)
        get :show, params: { id: project.to_param }

        # First call sets @project
        first_result = @controller.send(:current_project)
        # Second call should return the same memoized instance
        second_result = @controller.send(:current_project)

        _(first_result).must_equal project
        _(second_result).must_equal project
        _(first_result.object_id).must_equal second_result.object_id
      end
    end
  end
end

class TestController < ApplicationController
  before_action :session_required, only: :session_required_action
  before_action :admin_session_required, only: :admin_session_required_action

  def verify_api_xml
    head :ok
  end

  def renders_404
    render_404
  end

  def error_with_message
    error(message: 'test error string', status: :unauthorized)
  end

  def session_required_action
    head :ok
  end

  def admin_session_required_action
    head :ok
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

  def throws_missing_template
    raise ActionView::MissingTemplate.new(%w[path1 path2], 'template_name', %w[detail1 detail2], false, 'html')
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
  get 'test/throws_missing_template' => 'test#throws_missing_template'
end
Rails.application.routes.send(:eval_block, test_routes)
