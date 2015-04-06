class EnlistmentsController < SettingsController
  helper EnlistmentsHelper
  helper ProjectsHelper
  before_action :session_required, only: [:create, :new, :destroy, :edit, :update]
  before_action :find_project
  before_action :find_enlistment, only: [:show, :edit, :update, :destroy]
  before_action :project_context, only: [:index, :new, :edit]

  def index
    @enlistments = @project.enlistments
                   .includes(:project, :repository)
                   .filter_by(params[:query])
                   .send(parse_sort_term)
                   .paginate(page: params[:page], per_page: 10)
    # TODO: job model
    # @failed_jobs = @enlistments.joins([:project, [repository: :jobs]]).incomplete_job.failed_job.any?
    respond_to do |format|
      format.html
      format.xml
    end
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
    render :new, status: :unprocessable_entity && return unless @repository.valid?
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
    # TODO: project schedule_delayed_analysis
    # @enlistment.project.schedule_delayed_analysis(3.minutes)
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
    params.require(:repository).permit!
  end

  def parse_sort_term
    Enlistment.respond_to?("by_#{params[:sort]}") ? "by_#{params[:sort]}" : 'by_url'
  end

  def find_project
    @project = Project.from_param(params[:project_id]).take
    fail ParamRecordNotFound if @project.nil?
    @project.editor_account = current_user
  end

  def find_enlistment
    @enlistment = Enlistment.find_by(id: params[:id])
    fail ParamRecordNotFound if @enlistment.nil?
    @enlistment.editor_account = current_user
  end

  def initialize_repository
    @repository_class = params[:repository][:type].constantize
    @repository = @repository_class.get_compatible_class(params[:repository][:url]).new(repository_params)
  end

  def save_or_update_repository
    @project_has_repo_url = @project.enlistments.joins(:repository)
                            .where(repository: { url: params[:repository][:url] }).exists?
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
