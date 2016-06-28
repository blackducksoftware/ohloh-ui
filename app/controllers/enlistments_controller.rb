class EnlistmentsController < SettingsController
  helper EnlistmentsHelper
  helper ProjectsHelper

  before_action :session_required, :redirect_unverified_account, only: [:create, :new, :destroy, :edit, :update]
  before_action :set_project_or_fail
  before_action :set_project_editor_account_to_current_user
  before_action :find_enlistment, only: [:show, :edit, :update, :destroy]
  before_action :project_context, only: [:index, :new, :edit, :create, :update]

  def index
    @enlistments = @project.enlistments
                           .includes(:project, :repository, :code_location)
                           .filter_by(params[:query])
                           .send(parse_sort_term)
                           .paginate(page: page_param, per_page: 10)
    @failed_jobs = Enlistment.with_failed_repository_jobs.where(id: @enlistments.map(&:id)).any?
  end

  def show
    respond_to do |format|
      format.xml
    end
  end

  def new
    @repository = Repository.new
    @repository.build_prime_code_location
    @enlistment = Enlistment.new
  end

  def create
    initialize_repository
    return render :new, status: :unprocessable_entity unless @repository.valid?
    save_or_update_repository
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
    params.require(:repository).permit(:url, :username, :password, :bypass_url_validation,
                                       prime_code_location_attributes: [:branch_name])
  end

  def parse_sort_term
    Enlistment.respond_to?("by_#{params[:sort]}") ? "by_#{params[:sort]}" : 'by_url'
  end

  def find_enlistment
    @enlistment = Enlistment.find_by(id: params[:id])
    raise ParamRecordNotFound if @enlistment.nil?
    @enlistment.editor_account = current_user
  end

  def safe_constantize(repo)
    repo.constantize if %w(svnrepository svnsyncrepository repository hgrepository githubuser
                           gitrepository cvsrepository bzrrepository).include?(repo.downcase)
  end

  def initialize_repository
    @repository_class = safe_constantize(params[:repository][:type]).get_compatible_class(params[:repository][:url])
    @repository = @repository_class.new(repository_params)
  end

  def save_or_update_repository
    @project_has_repo_url = @project.enlistments.with_repo_url(@repository.url).exists?
    existing_repo = @repository_class.find_existing(@repository)
    if existing_repo.present?
      existing_repo.update_attributes(username: @repository.username, password: @repository.password)
      @repository = existing_repo
    else
      @repository.save! unless @project_has_repo_url
    end
  end

  def create_enlistment
    @repository.create_enlistment_for_project(current_user, @project) unless @project_has_repo_url
  end

  def set_flash_message
    return set_github_repos_message if @repository.is_a?(GithubUser)

    if @project_has_repo_url
      flash[:notice] = t('.notice', url: @repository.url)
    else
      branch_name = CGI.escapeHTML(@repository.prime_code_location.try(:branch_name).to_s)
      flash[:success] = t('.success', url: @repository.url, branch_name: branch_name)
    end
  end

  def set_github_repos_message
    flash[:notice] = t('.github_repos_added', username: @repository.url)
  end
end
