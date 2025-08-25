# frozen_string_literal: true

class ManagersController < SettingsController
  helper ProjectsHelper

  before_action :session_required, :redirect_unverified_account, except: :index
  before_action :set_project, if: -> { params[:project_id] }
  before_action :set_organization, if: -> { params[:organization_id] }
  before_action :fail_unless_parent
  before_action :find_manages, only: :index
  before_action :find_manage, except: :index
  before_action :show_permissions_alert, only: :index
  before_action :admin_session_required, only: %i[new create edit update], if: -> { @parent.is_a? Organization }
  before_action :project_context, if: -> { @parent.is_a? Project }

  def index; end

  def new
    # rubocop:disable Naming/MemoizedInstanceVariableName
    @manage ||= Manage.new
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end

  def edit
    render_unauthorized unless current_user_can_manage_or_self?
  end

  def create
    @manage ||= Manage.new
    @manage.assign_attributes(model_params.merge(target: @parent, account: current_user))
    if @manage.save
      flash[:success] = t '.success'
      redirect_to_index
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    return render_unauthorized unless current_user_can_manage_or_self?

    if @manage.update(model_params)
      flash[:notice] = t '.notice'
      redirect_to_index
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def approve
    return render_unauthorized unless current_user_can_manage?

    if @manage
      @manage.approve!(current_user)
      flash[:success] = t '.notice', name: ERB::Util.html_escape(@manage.account.name)
    end
    redirect_to_index
  end

  def reject
    return render_unauthorized unless current_user_can_manage_or_self?

    if @manage
      @manage.destroy_by!(current_user)
      flash[:notice] = t '.notice', name: ERB::Util.html_escape(@manage.account.name),
                                    target: ERB::Util.html_escape(@parent.name)
    end
    redirect_to_index
  end

  protected

  def current_user_can_manage_or_self?
    current_user_can_manage? || @manage.account == current_user
  end

  private

  def model_params
    params.require(:manage).permit(:message)
  end

  def find_manages
    @manages = Manage.where(target: @parent, deleted_by: nil).to_a
  end

  def find_manage
    account_name = params[:id] || current_user.login
    @manage = Manage.not_denied.for_target(@parent).for_account(Account.from_param(account_name).first!).first
  rescue ActiveRecord::RecordNotFound
    raise ParamRecordNotFound
  end

  def set_project
    @parent = @project = Project.by_vanity_url_or_id(params[:project_id]).take
    project_context && render('projects/deleted') if @project.try(:deleted?)
  end

  def set_organization
    @parent = @organization = Organization.from_param(params[:organization_id]).take
  end

  def fail_unless_parent
    raise ParamRecordNotFound unless @parent
  end

  def redirect_to_index
    redirect_to view_context.parent_managers_path(@parent)
  end
end
