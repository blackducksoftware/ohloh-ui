module EnlistmentFilters
  extend ActiveSupport::Concern

  included do
    before_action :session_required, :redirect_unverified_account, only: [:create, :new, :destroy, :edit, :update]
    before_action :set_project_or_fail
    before_action :set_project_editor_account_to_current_user
    before_action :check_project_authorization, except: [:index, :show]
    before_action :find_enlistment, only: [:show, :edit, :update, :destroy]
    before_action :project_context, only: [:index, :new, :edit, :create, :update]
    before_action :sidekiq_job_exists, only: :create
    before_action :handle_github_user_flow, only: :create
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
    if @project_has_repo_url
      flash[:notice] = t('.notice', url: @repository.url)
    else
      flash[:success] = t('.success', url: @repository.url,
                                      branch_name: (CGI.escapeHTML @repository.branch_name.to_s),
                                      module_name: (CGI.escapeHTML @repository.module_name.to_s))
    end
  end

  def sidekiq_job_exists
    key = Setting.get_project_enlistment_key(@project.id)
    job = Setting.get_value(key)
    if job.present? && job.key?(params[:repository][:url])
      redirect_to project_enlistments_path(@project), flash: { error: t('.job_exists') }
    end
  end

  def handle_github_user_flow
    return unless params[:repository][:type] == 'GithubUser'
    @repository = GithubUser.new(repository_params)
    return render :new, status: :unprocessable_entity unless @repository.valid?
    create_worker
  end

  def create_worker
    worker = EnlistmentWorker.perform_async(@repository.url, current_user.id, @project.id)
    Setting.update_worker(@project.id, worker, @repository.url)
    redirect_to project_enlistments_path(@project)
  end
end
