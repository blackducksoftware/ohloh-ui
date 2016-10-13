class ProjectsController < ApplicationController
  [AnalysesHelper, FactoidsHelper, MapHelper, RatingsHelper,
   RepositoriesHelper, TagsHelper].each { |help| helper help }

  [CiiBadge, TravisBadge] if Rails.env == 'development'

  layout 'responsive_project_layout', only: [:show, :badges]

  include ProjectFilters

  def index
    render template: @account ? 'projects/index_managed' : 'projects/index' if request_format == 'html'
  end

  def show
    render 'projects/no_analysis' if request.format.xml? && @analysis.blank?
  end

  def users
    @accounts = @project.users(params[:query], params[:sort])
    @accounts = @accounts.paginate(page: page_param, per_page: 10, total_entries: @accounts.length)
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
      flash.now[:error] = t('.failure')
      render :check_forge, status: :unprocessable_entity
    end
  end

  def check_forge
    if @projects.blank? || params[:bypass]
      populate_project_from_forge
    else
      flash.now[:notice] = (@projects.length == 1) ? t('.code_location_single') : t('.code_location_multiple')
      render template: 'projects/check_forge_duplicate'
    end
  end

  def similar_by_tags
    render partial: 'projects/show/similar_by_tags', locals: { similar_by_tags: @project.related_by_tags(4) }
  end

  def similar
    @similar_by_tags = @project.related_by_tags(10)
    @similar_by_stacks = @project.related_by_stacks(10)
  end

  def badges
    @badges = ProjectBadge.subclasses.map(&:name)
    @project_badge = ProjectBadge.new
  end

  def create_badge
    @project_badge = @project.project_badges.create(params[:project_badge].permit!)
    if @project_badge && @project.valid?
      render json: { success: true , content: render_to_string('_badges_table', :layout => false) }
    else
      render json: { success: false }
    end
  end

  def destroy_badge
    @badge = ProjectBadge.find(params[:badge_id])
    @badge.destroy
    redirect_to badges_project_path(@project)
  end

  def get_external_badge_url
    render json: { badge_template: render_badge_url_template}
  end
  private

  def project_params
    params.require(:project).permit([:name, :description, :vanity_url, :url, :download_url, :managed_by_creator,
                                     project_licenses_attributes: [:license_id],
                                     enlistments_attributes: [repository_attributes: [:type, :url, :branch_name]]])
  end

  def create_project_from_params
    @project = Project.new({ editor_account: current_user }.merge(project_params))
    @project.assign_editor_account_to_associations
    @project.manages.new(account: current_user) if project_params[:managed_by_creator].to_bool
  end

  def populate_project_from_forge
    Timeout.timeout(Forge::Match::MAX_FORGE_COMM_TIME) { @project = @match.project } if @match
  rescue Timeout::Error, OpenURI::HTTPError, URI::InvalidURIError
    flash.now[:notice] = t('.forge_time_out', name: @match.forge.name)
  end

  def render_badge_url_template
    if params[:badge_type] == "TravisBadge"
      TravisBadge.badge_template
    else
      CiiBadge.badge_template
    end
  end
end
