class LogosController < SettingsController
  helper ManagersHelper
  helper ProjectsHelper

  before_action :session_required, except: :new
  before_action :set_project_or_organization, only: [:destroy, :create, :new]
  before_action :set_editor_account_to_current_user, only: [:destroy, :create, :new]
  before_action :set_logo, only: :destroy
  around_action :edit_authorized?, only: :create
  before_action :show_permissions_alert, only: :new
  before_action :project_context, if: -> { @parent.is_a? Project }
  before_action :organization_context, if: -> { @parent.is_a? Organization }

  def new
    @logo = Logo.new
  end

  def create
    if create_logo
      update_parent_logo
      flash[:success] = t('.success')
      redirect_to action: :new
    else
      flash[:error] = t('.error')
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @parent.update_attribute(:logo_id, nil)
    @logo.destroy ? flash[:success] = t('.success') : flash[:error] = t('.error')
    redirect_to action: :new
  end

  private

  def edit_authorized?
    if @parent.edit_authorized?
      yield
    else
      redirect_to new_session_path, flash: { error: t('.permisson_denied') }
    end
  end

  def create_logo
    return true if params[:logo_id].present?

    @logo = Logo.new(logo_params)
    @logo.save
  end

  def update_parent_logo
    @parent.update_attribute(:logo_id, params[:logo_id] || @logo.id)
  end

  def set_project_or_organization
    @parent = if params[:project_id]
                @project = Project.by_url_name_or_id(params[:project_id]).take
              elsif params[:organization_id]
                @organization = Organization.from_param(params[:organization_id]).take
              end

    fail ParamRecordNotFound unless @parent
    project_context && render('projects/deleted') if @project.try(:deleted?)
  end

  def set_editor_account_to_current_user
    @parent.editor_account = current_user
  end

  def set_logo
    @logo = @parent.logo
  end

  def logo_params
    params.require(:logo).permit(:logo, :url, :attachment)
  end
end
