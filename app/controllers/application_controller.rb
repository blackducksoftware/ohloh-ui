# rubocop:disable Metrics/ClassLength
class ApplicationController < ActionController::Base
  include PageContextHelper

  helper AvatarHelper
  helper ButtonHelper
  helper BlogLinkHelper
  helper ColorsHelper

  protect_from_forgery with: :exception

  attr_reader :page_context
  helper_method :page_context

  before_action :store_location
  before_action :strip_query_param

  def initialize(*params)
    @page_context = {}
    super(*params)
  end

  rescue_from ParamRecordNotFound do
    render_404
  end

  protected

  # TODO: Fix me when sessions are real
  def session_required
    error(message: t(:must_be_logged_in), status: :unauthorized) unless logged_in?
  end

  def admin_session_required
    render_unauthorized unless current_user_is_admin?
  end

  def current_user
    return @cached_current_user if @cached_current_user_checked
    @cached_current_user_checked = true
    @cached_current_user = find_user_in_session || find_remembered_user || NilAccount.new
    session[:account_id] = @cached_current_user.id if @cached_current_user.id
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
    return false unless logged_in? && current_project
    return true if current_user_is_admin?
    logged_in? && current_project && current_project.active_managers.include?(current_user)
  end
  helper_method :current_user_can_manage?

  def current_project
    return @current_project if @current_project
    begin
      param = params[:project_id].presence || params[:id]
      @current_project ||= Project.from_param(param).first!
    rescue ActiveRecord::RecordNotFound
      raise ParamRecordNotFound
    end
    @current_project
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
    format
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
    return if request.xhr?
    session[:return_to] = request.fullpath
  end

  def redirect_back(default = root_path)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def must_own_account
    return if current_user == @account

    flash.now[:error] = t('cant_edit_other_account')
    access_denied
  end

  private

  def strip_query_param
    params[:query] = String.clean_string(params[:query])
  end

  def find_user_in_session
    Account.where(id: session[:account_id]).first
  end

  def find_remembered_user
    cookies[:auth_token] ? Account.where(remember_token: cookies[:auth_token]).first : nil
  end

  def access_denied
    store_location
    # TODO: Check if we really need width options.
    width_options = params[:width] && { width: 't' }
    redirect_to new_session_path(width_options)
  end
end
# rubocop:enable Metrics/ClassLength
