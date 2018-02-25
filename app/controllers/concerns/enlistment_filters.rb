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
    before_action :build_code_location, only: :create
    before_action :project_has_code_location?, only: :create
  end

  private

  def enlistment_params
    params.require(:enlistment).permit(:ignore)
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
    if job.present? && job.key?(code_location_params[:url])
      redirect_to project_enlistments_path(@project), flash: { error: t('.job_exists') }
    end
  end

  def handle_github_user_flow
    return unless code_location_params[:scm_type] == 'GithubUser'
    github_user = GithubUser.new(url: code_location_params[:url])
    @code_location = CodeLocation.new(url: code_location_params[:url])
    return create_worker if github_user.valid?
    @code_location.errors = github_user.errors
    render :new, status: :unprocessable_entity
  end

  def create_worker
    worker = EnlistmentWorker.perform_async(@code_location.url, current_user.id, @project.id)
    Setting.update_worker(@project.id, worker, @code_location.url)
    flash[:notice] = t('.github_repos_added', username: @code_location.url)
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
    @code_location = CodeLocation.new(code_location_params.merge(client_relation_id: @project.id))
  end

  def project_has_code_location?
    return unless CodeLocationSubscription.code_location_exists?(@project.id, @code_location.url,
                                                                 @code_location.branch, code_location_params[:scm_type])

    flash[:notice] = t('.notice', url: @code_location.url, module_branch_name: @code_location.branch)
    redirect_to project_enlistments_path(@project)
  end
end
