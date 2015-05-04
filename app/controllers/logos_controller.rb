class LogosController < SettingsController
  # before_action :check_project
  before_action :session_required, except: :new
  before_action :set_project_or_organization, only: [:destroy, :create, :new]
  before_action :set_logo, only: :destroy
  around_action :edit_authorized?, only: :create

  def new
    @logo = Logo.new
  end

  def create
    if create_logo
      update_parent_logo
      flash[:success] = t('.success')
    else
      flash[:error] = t('.error')
    end
    redirect_to action: :new
  end

  def destroy
    @project_or_organization.update_attribute(:logo_id, nil)
    @logo.destroy ? flash[:success] = t('.success') : flash[:error] = t('.error')
    redirect_to action: :new
  end

  private

  def edit_authorized?
    if @project_or_organization.edit_authorized?
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
    @project_or_organization.update_attribute(:logo_id, params[:logo_id] || @logo.id)
  end

  def set_project_or_organization
    @project_or_organization = if params[:project_id]
                                 @project = Project.from_param(params[:project_id]).take
                               elsif params[:organization_id]
                                 @organization = Organization.from_param(params[:organization_id]).take
                               end
    @project_or_organization.editor_account = current_user
  end

  def set_logo
    @logo = @project_or_organization.logo
  end

  def logo_params
    params.require(:logo).permit(:logo, :url, :attachment)
  end
end
