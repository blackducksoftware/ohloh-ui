class ProjectsController < ApplicationController
  helper RatingsHelper
  helper SearchablesHelper

  before_action :session_required, only: [:create, :new, :update]
  before_action :api_key_lock, only: [:index]
  before_action :find_account
  before_action :find_projects
  before_action :redirect_new_landing_page, only: :index

  def index
    respond_to do |format|
      format.html { render template: @account ? 'projects/index_managed' : 'projects/index' }
      format.xml
      format.atom
    end
  end

  def autocomplete
    @projects = Project.not_deleted.order('length(projects.name)').limit(25)
    @projects = @projects.where(['(lower(projects.name) like ?)', "%#{params[:term]}%"])
    @projects = @projects.where.not(id: params[:exclude_project_id].to_i) if params[:exclude_project_id].present?
  end

  private

  # TODO: this really belongs in app_controller, but that file is too big currently
  def api_key_lock
    return unless request_format == 'xml'
    api_key = ApiKey.in_good_standing.where(key: params[:api_key]).first
    render_unauthorized unless api_key && api_key.may_i_have_another?
  end

  def find_account
    @account = Account.in_good_standing.from_param(params[:account_id]).take
  end

  def find_projects
    parse_sort_term
    projects = Project.not_deleted.page(params[:page]).per_page(10).send(@sort)
    @projects = add_query_term(projects)
  end

  def add_query_term(projects)
    @query = params[:q] || params[:query]
    return projects unless @query
    arel_table = Project.arel_table
    projects.where(arel_table[:name].matches("%#{@query}%").or(arel_table[:description].matches("%#{@query}%")))
  end

  def parse_sort_term
    @sort_options = { 'by_activity_level' => t('projects.by_activity_level'),
                      'by_users' => t('projects.by_users'),
                      'by_new' => t('projects.by_new'),
                      'by_rating' => t('projects.by_rating'),
                      'by_active_committers' => t('projects.by_active_committers') }
    @sort = "by_#{params[:sort]}"
    @sort = 'by_new' unless @sort_options.key?(@sort)
  end

  def redirect_new_landing_page
    return unless @account.nil?
    redirect_to explore_projects_path if request.query_parameters.except('action').empty? && request_format == 'html'
  end
end
