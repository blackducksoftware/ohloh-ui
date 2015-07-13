class EnlistmentsController < SettingsController
  helper EnlistmentsHelper
  helper ProjectsHelper
  before_action :session_required, only: [:create, :new, :destroy, :edit, :update]
  before_action :set_project_or_fail
  before_action :set_project_editor_account_to_current_user
  before_action :find_enlistment, only: [:show, :edit, :update, :destroy]
  before_action :project_context, only: [:index, :new, :edit, :create, :update]

  def index
    @enlistments = @project.enlistments
                   .includes(:project, :repository)
                   .filter_by(params[:query])
                   .send(parse_sort_term)
                   .paginate(page: params[:page], per_page: 10)
    @failed_jobs = @enlistments.joins(project: :jobs, repository: :jobs)
                   .where(jobs: { status: Job::STATUS_FAILED }).any?
  end

  def show
    respond_to do |format|
      format.xml
    end
  end

  def new
    @repository = Repository.new
    @enlistment = Enlistment.new
  end

  def create
    initialize_repository
    return render :new, status: :unprocessable_entity unless @repository.valid?
    save_or_update_repository
    create_enlistment
    @first_enlistment = true if @project.enlistments.count == 1
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
    params.require(:repository).permit(:url, :module_name, :branch_name, :username, :password, :bypass_url_validation)
  end

  def parse_sort_term
    Enlistment.respond_to?("by_#{params[:sort]}") ? "by_#{params[:sort]}" : 'by_url'
  end

  def find_enlistment
    @enlistment = Enlistment.find_by(id: params[:id])
    fail ParamRecordNotFound if @enlistment.nil?
    @enlistment.editor_account = current_user
  end

  def safe_constantize(repo)
    repo.constantize if %w(svnrepository svnsyncrepository repository hgrepository
                           gitrepository cvsrepository bzrrepository).include?(repo.downcase)
  end

  def initialize_repository
    @repository_class = safe_constantize(params[:repository][:type]).get_compatible_class(params[:repository][:url])
    @repository = @repository_class.new(repository_params)
  end

  def save_or_update_repository
    @project_has_repo_url = @project.enlistments.with_repo_url(params[:repository][:url].strip).exists?
    existing_repo = @repository_class.find_existing(@repository)
    if existing_repo.present?
      existing_repo.update_attributes(username: @repository.username, password: @repository.password)
      @repository  = existing_repo
    else
      @repository.save! unless @project_has_repo_url
    end
  end

  def create_enlistment
    Enlistment.enlist_project_in_repository(current_user, @project, @repository)
  end

  def set_flash_message
    if @project_has_repo_url
      flash[:notice] = t('.notice', url: @repository.url)
    else
      flash[:success] = t('.success', url: @repository.url,
                                      branch_name: (CGI.escapeHTML @repository.branch_name),
                                      module_name: (CGI.escapeHTML @repository.module_name))
    end
  end
end
