# rubocop:disable Metrics/ClassLength
class ApplicationController < ActionController::Base
  include ClearanceSetup
  BOT_REGEX = /\b(Baiduspider|Googlebot|libwww-perl|msnbot|SiteUptime|Slurp)\b/i
  FORMATS_THAT_WE_RENDER_ERRORS_FOR = %w[html xml json].freeze

  include PageContextHelper

  helper FooterHelper

  helper PageContextHelper
  helper AvatarHelper
  helper ButtonHelper
  helper BlogLinkHelper
  helper ColorsHelper
  helper GithubHelper

  protect_from_forgery with: :exception

  attr_reader :page_context
  helper_method :page_context

  before_action :validate_request_format
  before_action :store_location
  before_action :handle_me_account_paths
  before_action :strip_query_param
  before_action :clear_reminder
  before_action :verify_api_access_for_xml_request, only: %i[show index]
  before_action :update_last_seen_at_and_ip

  alias session_required require_login

  def initialize(*params)
    @page_context = {}
    super(*params)
  end

  def validate_request_format
    render_404 if request.format.nil?
  end

  rescue_from ::Exception do |exception|
    raise exception if Rails.application.config.consider_all_requests_local
    request.env[:user_agent] = request.user_agent
    case exception
    when SocketError, Errno::ECONNREFUSED, FisbotApiError
      NewRelic::Agent.notice_error(exception)
      flash[:notice] = t(:api_exception)
      redirect_back
    else
      notify_airbrake(exception) unless blank_user_agent?
      render_404
    end
  end

  rescue_from ParamRecordNotFound, ActionController::UnknownFormat, ActionController::RoutingError do
    render_404
  end

  def avoid_global_search
    @avoid_global_search = true
  end

  # Any ActionController::RoutingError raised by ActionDispatch is not caught by ActionController.
  # See: https://github.com/rails/rails/issues/671
  def raise_not_found!
    raise ActionController::RoutingError, "No route matches #{params[:unmatched_route]}"
  end

  def page_param
    [params[:page].to_i, 1].max
  end
  helper_method :page_param

  protected

  def handle_me_account_paths
    return unless params[:account_id] == 'me'
    if current_user.nil?
      redirect_to new_session_path
    else
      params[:account_id] = current_user.login
    end
  end

  def custom_description_error
    I18n.t('project_tags.description_error_message_html', url: edit_project_url(@project))
  end

  def admin_session_required
    render_unauthorized unless current_user_is_admin?
  end

  def logged_in?
    signed_in?
  end
  helper_method :logged_in?

  def current_user_is_admin?
    current_user.access.admin?
  end
  helper_method :current_user_is_admin?

  def current_user_can_manage?
    return true if current_user_is_admin?
    logged_in? && current_project_or_org && current_project_or_org.active_managers.include?(current_user)
  end
  helper_method :current_user_can_manage?

  def current_project_or_org
    @parent ||= @project || @organization || current_project
    @parent
  end

  def current_project
    begin
      @project ||= Project.from_param(params[:project_id] || params[:id]).first!
    rescue ActiveRecord::RecordNotFound
      raise ParamRecordNotFound
    end
    @project
  end
  helper_method :current_project

  def read_only_mode?
    ENV['READ_ONLY_MODE'].present?
  end
  helper_method :read_only_mode?

  def disabled_during_read_only_mode
    # Pass '?admin=1' in the URL to open the backdoor.
    # The backdoor allows users to avoid the redirect, but it doesn't actually allow login.
    redirect_to maintenance_path if read_only_mode? && !params[:admin]
  end

  def request_format
    format = request.format.html? ? 'html' : params[:format]
    format = nil unless Mime::EXTENSION_LOOKUP.key?(format)
    format || 'html'
  end

  def error(message:, status:)
    params[:format] = 'html' unless FORMATS_THAT_WE_RENDER_ERRORS_FOR.include?(request_format)
    @error = { message: message }
    @page_context = {}
    render_with_format 'error', status: status
  end

  def render_404
    response.content_type = 'text/html'
    error message: t(:four_oh_four), status: :not_found
  end

  def render_unauthorized
    error(message: t(:not_authorized), status: :unauthorized)
  end

  def render_missing_api_key
    error(message: t(:missing_api_key), status: :bad_request)
  end

  def render_invalid_api_key
    error(message: t(:invalid_api_key), status: :bad_request)
  end

  def render_limit_exceeded_api_key(limit)
    error(message: t(:overlimit_api_key, limit: limit), status: :unauthorized)
  end

  def render_with_format(action, status: :ok)
    render "#{action}.#{request_format}", layout: 'application', status: status
  end

  def clear_reminder
    return unless params[:clear_action_reminder]
    action = current_user.actions.where(id: params[:clear_action_reminder]).first
    action.update_attributes(status: Action::STATUSES[:completed]) if action
  end

  def store_location
    return if request.xhr? || request.post? || request_format != 'html'
    session[:return_to] = request.fullpath
  end

  def redirect_back(default = root_path)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def must_own_account
    return if current_user == @account

    if current_user_is_admin?
      flash.now[:error] = t(:admin_warning)
      return
    end

    flash.now[:error] = t(:cant_edit_other_account)
    access_denied
  end

  def bot?
    (request.env['HTTP_USER_AGENT'] =~ BOT_REGEX).present?
  end

  def blank_user_agent?
    request.env['HTTP_USER_AGENT'].blank?
  end

  def show_permissions_alert
    return if current_user_can_manage?
    return if logged_in? && !current_project_or_org.protection_enabled?
    flash.now[:notice] = logged_in? ? t('permissions.not_manager') : t('permissions.must_log_in')
  end

  private

  def verify_api_access_for_xml_request
    return unless request_format == 'xml'
    return render_missing_api_key if params[:api_key].blank?
    verify_api_key_standing
  end

  def verify_api_key_standing
    api_key = ApiKey.in_good_standing.find_for_oauth_application_uid(api_client_id)
    if api_key && api_key.may_i_have_another?
      doorkeeper_authorize! if doorkeeper_token
    elsif api_key && api_key.send(:exceeded_daily_allotment?)
      render_limit_exceeded_api_key(api_key.daily_limit)
    else
      render_invalid_api_key
    end
  end

  def api_client_id
    params[:api_key] || (doorkeeper_token && doorkeeper_token.application && doorkeeper_token.application.uid)
  end

  def strip_query_param
    params[:query] ||= params[:q]
    params[:query] = String.clean_string(params[:query])
  end

  def access_denied
    store_location
    redirect_to new_session_path
  end

  def set_session_projects
    @session_projects = (session[:session_projects] || []).map do |vanity_url|
      Project.from_param(vanity_url).take
    end.compact.uniq
  end

  def redirect_unverified_account
    redirect_for_email_activation || redirect_for_spammer_verification
  end

  def redirect_for_email_activation
    return if current_user.access.activated?

    flash[:notice] = t('accounts.non_activated_message')
    redirect_to new_activation_resend_path
  end

  def redirect_for_spammer_verification
    return if current_user && !current_user.access.disabled? && current_user.access.mobile_or_oauth_verified?
    redirect_to new_authentication_path
  end

  def current_user_is_verified?
    current_user && current_user.access.verified?
  end
  helper_method :current_user_is_verified?

  def set_project_or_fail
    project_id = params[:project_id] || params[:id]
    @project = Project.by_vanity_url_or_id(project_id).take

    raise ParamRecordNotFound unless @project
    project_context
    render 'projects/deleted' if @project.deleted?
  end

  def set_project_editor_account_to_current_user
    @project.editor_account = current_user
  end

  def check_project_authorization
    render_unauthorized unless @project.edit_authorized?
  end

  def update_last_seen_at_and_ip
    return unless logged_in?
    # rubocop:disable Rails/SkipsModelValidations # We want to skip validations here.
    current_user.update_columns(last_seen_at: Time.current, last_seen_ip: request.remote_ip)
  end
end
# rubocop:enable Metrics/ClassLength
