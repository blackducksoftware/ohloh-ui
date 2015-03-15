class ProjectsController < ApplicationController
  helper AnalysesHelper
  helper FactoidsHelper
  helper RatingsHelper

  before_action :session_required, only: [:create, :new, :update]
  before_action :api_key_lock, only: [:index]
  before_action :find_account
  before_action :find_projects, only: [:index]
  before_action :find_project, only: [:show, :edit, :update, :estimated_cost, :users]
  before_action :redirect_new_landing_page, only: :index

  def index
    respond_to do |format|
      format.html { render template: @account ? 'projects/index_managed' : 'projects/index' }
      format.xml
      format.atom
    end
  end

  def show
    @analysis = @project.best_analysis
    @rating = logged_in? ? @project.ratings.where(account_id: current_user.id).first : nil
    @score = @rating ? @rating.score : 0
  end

  def users
    accounts = @project.users.paginate(page: params[:page], per_page: 10)
    accounts = filter_project_users(accounts)
    @accounts = sort_project_users(accounts)
  end

  def update
    return render_unauthorized unless @project.edit_authorized?
    if @project.update_attributes(project_params)
      flash[:notice] = t '.success'
      redirect_to project_path(@project)
    else
      render :edit, status: :unprocessable_entity
    end
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
    projects = @account ? @account.projects.not_deleted : Project.not_deleted
    @projects = add_query_term(projects.page(params[:page]).per_page(10).send(@sort))
  end

  def add_query_term(projects)
    @query = params[:q] || params[:query]
    return projects unless @query
    arel_table = Project.arel_table
    projects.where(arel_table[:name].matches("%#{@query}%").or(arel_table[:description].matches("%#{@query}%")))
  end

  def parse_sort_term
    @sort_options = @account ? account_projects_sort_options : projects_sort_options
    @sort = "by_#{params[:sort]}"
    @sort = (@account ? 'by_users' : 'by_new') unless @sort_options.key?(@sort)
  end

  def account_projects_sort_options
    { 'by_new' => t('projects.by_new'),
      'by_users' => t('projects.by_users'),
      'by_project_name' => t('projects.by_project_name') }
  end

  def projects_sort_options
    { 'by_activity_level' => t('projects.by_activity_level'),
      'by_users' => t('projects.by_users'),
      'by_new' => t('projects.by_new'),
      'by_rating' => t('projects.by_rating'),
      'by_active_committers' => t('projects.by_active_committers') }
  end

  def find_project
    @project = Project.not_deleted.from_param(params[:id]).take
    fail ParamRecordNotFound unless @project
    @project.editor_account = current_user
  end

  def project_params
    params.require(:project).permit([:name, :description, :url_name])
  end

  def redirect_new_landing_page
    return unless @account.nil?
    redirect_to explore_projects_path if request.query_parameters.except('action').empty? && request_format == 'html'
  end

  def filter_project_users(accounts)
    return accounts if params[:query].blank?
    accounts.where("lower(name) LIKE '%#{params[:query].downcase}%'")
  end

  def sort_project_users(accounts)
    valid_sort = SORT_OPTIONS[:project_users][:options].collect { |_key, value| value }.include?(params[:sort])
    sort_by = valid_sort ? params[:sort] : 'kudo_position'
    accounts.order("#{sort_by} ASC")
  end
end
