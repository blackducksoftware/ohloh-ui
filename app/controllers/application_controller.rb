# rubocop:disable Metrics/ClassLength
class ApplicationController < ActionController::Base
  BOT_REGEX = /\b(Baiduspider|Googlebot|libwww-perl|msnbot|SiteUptime|Slurp)\b/i

  include PageContextHelper

  helper FooterHelper

  helper PageContextHelper
  helper AvatarHelper
  helper ButtonHelper
  helper BlogLinkHelper
  helper ColorsHelper

  protect_from_forgery with: :exception

  attr_reader :page_context
  helper_method :page_context

  before_action :store_location
  before_action :strip_query_param
  before_action :clear_reminder
  before_action :verify_api_access_for_xml_request, only: [:show, :index]

  def initialize(*params)
    @page_context = {}
    super(*params)
  end

  rescue_from ::Exception do |exception|
    fail exception if Rails.application.config.consider_all_requests_local
    notify_airbrake(exception)
    render_404
  end

  rescue_from ParamRecordNotFound, ActionController::RoutingError do
    render_404
  end

  # Any ActionController::RoutingError raised by ActionDispatch is not caught by ActionController.
  # See: https://github.com/rails/rails/issues/671
  def raise_not_found!
    fail ActionController::RoutingError, "No route matches #{params[:unmatched_route]}"
  end

  protected

  def session_required
    return if logged_in?
    flash[:notice] = t('sessions.message_html', href: new_account_path)
    access_denied
  end

  def admin_session_required
    render_unauthorized unless current_user_is_admin?
  end

  def current_user
    return @cached_current_user if @cached_current_user_checked
    @cached_current_user_checked = true
    @cached_current_user = find_previous_user || NilAccount.new
    session[:account_id] = @cached_current_user.id
    @cached_current_user
  end
  helper_method :current_user

  def logged_in?
    current_user.id != nil
  end
  helper_method :logged_in?

  def current_user_is_admin?
    Account::Access.new(current_user).admin?
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
    format = 'html' if request.format.html?
    format ||= params[:format]
    format || 'html'
  end

  def error(message:, status:)
    @error = { message: message }
    render_with_format 'error', status: status
  end

  def render_404
    error message: t(:four_oh_four), status: :not_found
  end

  def render_unauthorized
    error(message: t(:not_authorized), status: :unauthorized)
  end

  def render_with_format(action, status: :ok)
    render "#{action}.#{request_format}", status: status
  end

  def clear_reminder
    return unless params[:clear_action_reminder]
    action = current_user.actions.where(id: params[:clear_action_reminder]).first
    action.update_attributes(status: Action::STATUSES[:completed]) if action
  end

  def store_location
    return if request.xhr? || request_format != 'html'
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

  def show_permissions_alert
    return if current_user_can_manage?
    return if logged_in? && !current_project_or_org.protection_enabled?
    flash.now[:notice] = logged_in? ? t('permissions.not_manager') : t('permissions.must_log_in')
  end

  private

  def verify_api_access_for_xml_request
    return unless request_format == 'xml'
    api_key = ApiKey.in_good_standing.find_by_oauth_application_uid(api_client_id)

    if api_key && api_key.may_i_have_another?
      doorkeeper_authorize! if doorkeeper_token
    else
      render_unauthorized
    end
  end

  def api_client_id
    params[:api_key] || (doorkeeper_token && doorkeeper_token.application && doorkeeper_token.application.uid)
  end

  def strip_query_param
    params[:query] = String.clean_string(params[:query])
  end

  def find_user_in_session
    Account.where(id: session[:account_id]).first
  end

  def find_remembered_user
    cookies[:auth_token] ? Account.where(remember_token: cookies[:auth_token]).first : nil
  end

  def find_previous_user
    previous_user = find_user_in_session || find_remembered_user
    previous_user = nil if previous_user && Account::Access.new(previous_user).spam?
    previous_user
  end

  def access_denied
    store_location
    redirect_to new_session_path
  end

  def set_session_projects
    @session_projects = (session[:session_projects] || []).map do |url_name|
      Project.from_param(url_name).take
    end.compact.uniq
  end

  def set_project_or_fail
    project_id = params[:project_id] || params[:id]
    @project = Project.by_url_name_or_id(project_id).take

    fail ParamRecordNotFound unless @project
    render 'projects/deleted' if @project.deleted?
  end

  def set_project_editor_account_to_current_user
    @project.editor_account = current_user
  end
end
# rubocop:enable Metrics/ClassLength
