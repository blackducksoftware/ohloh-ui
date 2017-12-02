module EnlistmentFilters
  extend ActiveSupport::Concern

  included do
    before_action :session_required, :redirect_unverified_account, only: [:create, :new, :destroy, :edit, :update]
    before_action :set_project_or_fail
    before_action :set_project_editor_account_to_current_user
    before_action :check_project_authorization, except: [:index, :show]
    before_action :find_enlistment, only: [:show, :edit, :update, :destroy]
    before_action :project_context, only: [:index, :new, :edit, :create, :update]
    before_action :validate_project, only: [:edit, :update, :destroy]
    before_action :sidekiq_job_exists, only: :create
    before_action :handle_github_user_flow, only: :create
    before_action :valid_code_location?, only: :create
    before_action :code_location_exist?, only: :create
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
    raise ParamRecordNotFound unless @enlistment
    @enlistment.editor_account = current_user
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
    @code_location = CodeLocation.new
    return render :new, status: :unprocessable_entity unless @repository.valid?
    create_worker
  end

  def create_worker
    worker = EnlistmentWorker.perform_async(@repository.url, current_user.id, @project.id)
    Setting.update_worker(@project.id, worker, @repository.url)
    flash[:notice] = t('.github_repos_added', username: @repository.url)
    redirect_to project_enlistments_path(@project)
  end

  def validate_project
    unless @project.valid?
      error_msg = @project.errors.include?(:description) ? add_custom_error_msg : @project.errors.full_messages
      flash[:error] = error_msg.join(', ')
      redirect_to project_enlistments_path
    end
  end

  def add_custom_error_msg
    project_errors = @project.errors
    project_errors.delete(:description)
    project_errors.full_messages.unshift(custom_description_error)
  end

  def build_code_location
    CodeLocationBuilder.build do |builder|
      builder.type = params[:repository][:type]
      builder.url = params[:repository][:url]
      builder.repo_params = repository_params
      builder.code_location_params = code_location_params
    end
  end

  def valid_code_location?
    @code_location = build_code_location
    @repository = @code_location.repository
    return render :new, status: :unprocessable_entity unless @code_location.valid?
  end

  def code_location_exist?
    code_location = CodeLocation.find_existing(@repository.url, @code_location.module_branch_name)
    return unless code_location
    update_repo_username_and_password(code_location)

    flash[:notice] = t('.notice', url: @repository.url, module_branch_name: @code_location.module_branch_name)
    redirect_to project_enlistments_path(@project)
  end

  def update_repo_username_and_password(code_location)
    code_location.repository.update_attributes(username: @repository.username, password: @repository.password)
  end
end
