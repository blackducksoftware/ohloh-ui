class ProjectLicensesController < ApplicationController
  helper ProjectsHelper

  before_action :find_project
  before_action :project_context
  before_action :project_edit_authorized, only: [:create, :destroy]

  def index
    @licenses = @project.licenses
  end

  def new
    @licenses = License.all
  end

  def create
    project_license = ProjectLicense.new(project_license_params)
    begin
      project_license.save!
      flash[:success] = t('.success')
      redirect_to action: :index
    rescue
      handle_creation_errors(project_license)
    end
  end

  private

  def project_license_params
    params.require(:project_license).permit([:license_id]).merge(project: @project, editor_account: current_user)
  end

  def find_project
    @project = Project.not_deleted.from_param(params[:project_id]).take
    @project.editor_account = current_user
    fail ParamRecordNotFound unless @project
  end

  def project_edit_authorized
    return if @project.edit_authorized?
    flash.now[:notice] = t(:not_authorized)
    redirect_to project_path(@project)
  end

  def handle_creation_errors(project_license)
    msgs = project_license.errors.messages[:license_id]
    already_added = (msgs && msgs.include?(t('errors.messages.taken')))
    flash.now[:notice] = already_added ? t('.error_already_exists') : t('.error_other')
    @licenses = License.all
    render action: :new, status: :unprocessable_entity
  end
end
