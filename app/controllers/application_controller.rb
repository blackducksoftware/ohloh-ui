class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  attr_reader :page_context
  helper_method :page_context

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
    error(message: t(:must_be_logged_in), status: :unauthorized) unless current_user
  end

  def admin_session_required
    error(message: t(:not_authorized), status: :unauthorized) unless current_user_is_admin?
  end

  # TODO: Fix me when sessions are real
  def current_user
    nil
  end
  helper_method :current_user

  def current_user_is_admin?
    current_user && current_user.admin?
  end
  helper_method :current_user_is_admin?

  def current_user_can_manage?
    return true if current_user_is_admin?
    current_user && current_project && current_project.active_managers.include?(current_user)
  end
  helper_method :current_user_can_manage?

  def current_project
    begin
      param = params[:project_id].blank? ? params[:id] : params[:project_id]
      @current_project ||= Project.find_by_url_name(param)
    rescue ActiveRecord::RecordNotFound
      raise ParamRecordNotFound
    rescue e
      raise e
    end
    @current_project
  end
  helper_method :current_project

  def read_only_mode?
    false
  end
  helper_method :read_only_mode?

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

  def render_with_format(action, status: :ok)
    render "#{action}.#{request_format}", status: status
  end
end
