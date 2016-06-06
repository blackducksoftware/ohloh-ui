class EnlistmentsController < SettingsController
  helper EnlistmentsHelper
  helper ProjectsHelper

  include EnlistmentFilters

  def index
    @enlistments = @project.enlistments.includes(code_location: :repository)
                           .filter_by(params[:query]).send(parse_sort_term)
                           .paginate(page: page_param, per_page: 10)
    @failed_jobs = Enlistment.failed_code_location_jobs.where(id: @enlistments.map(&:id)).any?
  end

  def show
    respond_to do |format|
      format.xml
    end
  end

  def new
    @repository = Repository.new
    @code_location = CodeLocation.new
    @enlistment = Enlistment.new
  end

  def create
    initialize_repository
    initialize_code_location
    return render :new, status: :unprocessable_entity unless @code_location.valid?
    save_or_update_code_location
    create_enlistment
    flash[:show_first_enlistment_alert] = true if @project.enlistments.count == 1
    set_flash_message
    redirect_to project_enlistments_path(@project)
  end

  def edit
    @examples = @enlistment.ignore_examples
  end

  def update
    @enlistment.update(enlistment_params)
    @enlistment.project.schedule_delayed_analysis(3.minutes)
    redirect_to project_enlistments_path(@project), flash: { success: t('.success') }
  end

  def destroy
    @enlistment.create_edit.undo!(current_user)
    redirect_to project_enlistments_path(@project), flash: { success: t('.success', name: @project.name) }
  end

  private

  def enlistment_params
    params.require(:enlistment).permit(:ignore)
  end

  def repository_params
    params.require(:repository).permit(:url, :username, :password, :bypass_url_validation)
  end

  def code_location_params
    params.require(:code_location).permit(:module_branch_name, :bypass_url_validation) if params[:code_location]
  end

  def parse_sort_term
    Enlistment.respond_to?("by_#{params[:sort]}") ? "by_#{params[:sort]}" : 'by_url'
  end

  def safe_constantize(repo)
    repo.constantize if %w(svnrepository svnsyncrepository repository hgrepository githubuser
                           gitrepository cvsrepository bzrrepository).include?(repo.downcase)
  end

  def initialize_repository
    @repository_class = safe_constantize(params[:repository][:type]).get_compatible_class(params[:repository][:url])
    @repository = @repository_class.new(repository_params)
  end

  def initialize_code_location
    if @repository.is_a?(GithubUser)
      @code_location = @repository
    else
      @code_location = CodeLocation.new(code_location_params)
      @code_location.repository = @repository
    end
  end

  def save_or_update_code_location
    @project_has_repo_url = @project.enlistments.with_repo_url(@repository.url).exists?
    return if @project_has_repo_url

    code_location = CodeLocation.find_existing(@repository.url, @code_location.module_branch_name)

    return @code_location.save! unless code_location

    code_location.repository.update_attributes(username: @repository.username, password: @repository.password)
    @code_location = code_location
  end

  def create_enlistment
    @code_location.create_enlistment_for_project(current_user, @project) unless @project_has_repo_url
  end

  def set_flash_message
    return set_github_repos_message if @repository.is_a?(GithubUser)

    if @project_has_repo_url
      flash[:notice] = t('.notice', url: @repository.url)
    else
      flash[:success] = t('.success', url: @repository.url,
                                      module_branch_name: (CGI.escapeHTML @code_location.module_branch_name.to_s))
    end
  end

  def set_github_repos_message
    flash[:notice] = t('.github_repos_added', username: @repository.url)
  end
end
