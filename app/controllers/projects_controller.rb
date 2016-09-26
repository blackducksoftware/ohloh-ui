class ProjectsController < ApplicationController
  [AnalysesHelper, FactoidsHelper, MapHelper, RatingsHelper,
   RepositoriesHelper, TagsHelper, VulnerabilitiesHelper].each { |help| helper help }

  layout 'responsive_project_layout', only: [:show, :security]

  include ProjectFilters
  include VulnerabilitiesHelper

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

  def security
  end

  def vulnerabilities_filter
    render layout: false
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

  def find_security_data
    return unless best_security_set && best_security_set.releases.present?
    find_latest_version
    find_minor_versions
    find_vulnerabilities
  end

  def best_security_set
    @project.best_project_security_set
  end

  def find_latest_version
    @latest_version = Release.find_by_id(filter_version_param) ||
                      best_security_set.find_latest_release_from_major_version(filter_major_version_param) ||
                      best_security_set.releases.latest
  end

  def find_minor_versions
    @minor_versions = if filter_major_version_param.present?
                        @latest_version.minor_versions.sort_by_release_date
                      else
                        best_security_set.releases.sort_by_release_date
                      end
    @minor_versions = @minor_versions.where("(released_on::DATE <= NOW()::DATE) AND \
      (released_on::DATE >= (NOW() - '#{filter_period_param} year'::INTERVAL)::DATE)") if filter_period_param.present?
  end

  def find_vulnerabilities
    return unless @latest_version && @minor_versions.present?
    @vulnerabilities = @latest_version.vulnerabilities
    @vulnerabilities = @vulnerabilities.send(filter_severity_param) if @vulnerabilities.present? &&
                                                                       filter_severity_param
    @vulnerabilities = @vulnerabilities.sort_by_cve_id.paginate(page: page_param, per_page: 10)
  end
end
