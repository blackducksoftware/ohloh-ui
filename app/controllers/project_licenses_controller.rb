# frozen_string_literal: true

class ProjectLicensesController < SettingsController
  helper ProjectsHelper

  before_action :set_project_or_fail, :set_project_editor_account_to_current_user
  before_action :project_context
  before_action :project_edit_authorized, only: %i[create destroy]
  before_action :find_project_license, only: [:destroy]

  def index
    @project_licenses = @project.project_licenses.includes(:license).order('licenses.vanity_url ASC')
  end

  def new
    @licenses = License.all
  end

  def create
    create_project_license
    flash[:success] = t('.success')
    redirect_to action: :index
  rescue StandardError
    handle_creation_errors(@project_license)
  end

  def destroy
    flash[:notice] = @project_license.destroy ? t('.success') : t('.error')
    redirect_to action: :index
  end

  private

  def create_project_license
    @project_license = ProjectLicense.where(project_license_params.merge(deleted: true)).first
    if @project_license
      CreateEdit.where(target: @project_license).first.redo!(current_user)
    else
      @project_license = ProjectLicense.new(project_license_params.merge(editor_account: current_user))
      @project_license.save!
    end
  end

  def project_license_params
    params.permit([:license_id]).merge(project: @project)
  end

  def find_project_license
    @project_license = ProjectLicense.where(id: params[:id], project_id: @project.id).take
    raise ParamRecordNotFound unless @project_license

    @project_license.editor_account = current_user
  end

  def project_edit_authorized
    return if @project.edit_authorized?

    flash.now[:notice] = t(:not_authorized)
    redirect_to project_path(@project)
  end

  def handle_creation_errors(project_license)
    msgs = project_license.errors.messages[:license_id]
    already_added = (msgs&.include?(t('errors.messages.taken')))
    flash.now[:notice] = already_added ? t('.error_already_exists') : t('.error_other')
    @licenses = License.all
    render action: :new, status: :unprocessable_entity
  end
end
