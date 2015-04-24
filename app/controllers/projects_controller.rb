class ProjectsController < ApplicationController
  [AnalysesHelper, FactoidsHelper, MapHelper, RatingsHelper, RepositoriesHelper, TagsHelper].each { |help| helper help }

  before_action :session_required, only: [:check_forge, :create, :new, :update]
  before_action :api_key_lock, only: [:index]
  before_action :find_account
  before_action :find_projects, only: [:index]
  before_action :find_project, only: [:show, :edit, :update, :estimated_cost, :users, :settings, :map, :similar_by_tags]
  before_action :redirect_new_landing_page, only: :index
  before_action :find_forge_matches, only: :check_forge
  before_action :project_context, only: [:show, :users, :estimated_cost, :edit, :settings, :map]
  before_action :show_permissions_alert, only: [:settings]

  def index
    render template: @account ? 'projects/index_managed' : 'projects/index' if request_format == 'html'
  end

  def show
    @analysis = @project.best_analysis
    @rating = logged_in? ? @project.ratings.where(account_id: current_user.id).first : nil
    @score = @rating ? @rating.score : 0
  end

  def users
    @accounts = @project.users(params[:query], params[:sort])
                .paginate(page: params[:page], per_page: 10,
                          total_entries: @project.users.count('DISTINCT(accounts.id)'))
  end

  def update
    return render_unauthorized unless @project.edit_authorized?
    if @project.update_attributes(project_params)
      redirect_to project_path(@project), notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    create_project_from_params
    if @project.save
      redirect_to project_path(@project)
    else
      render :check_forge, status: :unprocessable_entity, notice: t('.failure')
    end
  end

  def check_forge
    if @projects.blank? || params[:bypass]
      populate_project_from_forge
    else
      flash.now[:notice] =  (@projects.length == 1) ? t('.code_location_single') : t('.code_location_multiple')
      render template: 'projects/check_forge_duplicate'
    end
  end

  def similar_by_tags
    render partial: 'projects/show/similar_by_tags', locals: { similar_by_tags: @project.related_by_tags(4) }
  end

  private

  # TODO: this really belongs in app_controller, but that file is too big currently
  def api_key_lock
    return unless request_format == 'xml'
    api_key = ApiKey.in_good_standing.where(key: params[:api_key]).first
    render_unauthorized unless api_key && api_key.may_i_have_another?
  end

  def find_account
    @account = Account.from_param(params[:account_id]).take
  end

  def find_projects
    @projects = find_projects_by_params.page(params[:page]).per_page([25, (params[:per_page] || 10).to_i].min).to_a
  rescue
    raise ParamRecordNotFound
  end

  def find_projects_by_params
    projects = @account ? @account.projects.not_deleted : Project.not_deleted
    projects.by_collection(params[:ids], params[:sort], params[:query])
  end

  def find_project
    @project = Project.from_param(params[:id]).take
    fail ParamRecordNotFound unless @project
    @project.editor_account = current_user
  end

  def project_params
    params.require(:project).permit([:name, :description, :url_name, :url, :download_url, :managed_by_creator,
                                     project_licenses_attributes: [:license_id],
                                     enlistments_attributes: [repository_attributes: [:type, :url, :branch_name]]])
  end

  def redirect_new_landing_page
    return unless @account.nil?
    redirect_to projects_explores_path if request.query_parameters.except('action').empty? && request_format == 'html'
  end

  def find_forge_matches
    @match = Forge::Match.first(params[:codelocation])
    return unless @match
    @projects = Project.where(id: Repository.matching(@match).joins(:projects).select('projects.id')).not_deleted
  end

  def create_project_from_params
    @project = Project.new({ editor_account: current_user }.merge(project_params))
    @project.assign_editor_account_to_associations
    @project.manages.new(account: current_user) if project_params[:managed_by_creator].to_bool
  end

  def populate_project_from_forge
    Timeout.timeout(Forge::Match::MAX_FORGE_COMM_TIME) { @project = @match.project } if @match
  rescue Timeout::Error
    flash.now[:notice] = t('.forge_time_out', name: @match.forge.name)
  end
end
