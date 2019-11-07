# frozen_string_literal: true

# rubocop:disable SkipsModelValidations

module ProjectFilters
  extend ActiveSupport::Concern

  included do
    before_action :session_required, :redirect_unverified_account, only: %i[check_forge create new update]
    before_action :find_account
    before_action :find_projects, only: [:index]
    before_action :set_project_or_fail, :set_project_editor_account_to_current_user,
                  only: %i[show edit update estimated_cost users settings
                           map similar_by_tags similar badges create_badge destroy_badge]
    before_action :redirect_new_landing_page, only: :index
    before_action :find_duplicate_projects, only: :check_forge
    before_action :project_context, only: %i[show users estimated_cost edit settings map similar update]
    before_action :show_permissions_alert, only: %i[settings edit]
    before_action :set_session_projects, only: :index
    before_action :set_rating_and_score, only: :show
    before_action :set_uuid, only: :show
    before_action :avoid_global_search_if_parent_is_account, only: :index
    before_action :avoid_global_search, only: :users
  end

  def create; end

  def new; end

  def index; end

  def show; end

  def edit; end

  def update; end

  private

  def avoid_global_search_if_parent_is_account
    avoid_global_search if params[:account_id].present?
  end

  def find_account
    @account = Account.from_param(params[:account_id]).take
  end

  def find_projects
    @projects = find_projects_by_params.page(page_param).per_page([25, (params[:per_page] || 10).to_i].min).to_a
  rescue StandardError
    raise ParamRecordNotFound
  end

  def find_projects_by_params
    @sort = params[:sort]
    projects = @account ? @account.projects.not_deleted : Project.not_deleted
    projects.by_collection(params[:ids], @sort, params[:query])
  end

  def find_duplicate_projects
    url = params[:codelocation]
    @projects = Project.not_deleted.joins(:enlistments)
                       .where(enlistments: { code_location_id: CodeLocation.all(url: url).map(&:id) })
  end

  def set_rating_and_score
    @analysis = @project.best_analysis
    @rating = logged_in? ? @project.ratings.where(account_id: current_user.id).first : nil
    @score = @rating ? @rating.score : 0
  end

  def redirect_new_landing_page
    return unless @account.nil?

    redirect_to projects_explores_path if request.query_parameters.except('action').empty? && request_format == 'html'
  end

  def set_uuid
    return if @project.uuid.present?

    uuid = OpenhubSecurity.get_uuid(@project.name)
    @project.update_column('uuid', uuid) if uuid
  end
end

# rubocop:enable SkipsModelValidations
