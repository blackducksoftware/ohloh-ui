module PositionFilters
  extend ActiveSupport::Concern

  included do
    before_action :session_required, :redirect_unverified_account,
                  only: [:edit, :new, :create, :delete, :one_click_create]
    before_action :set_account
    before_action :must_own_account, only: [:edit, :update, :new, :create, :one_click_create]
    before_action :redirect_to_languages, only: :show, if: :params_id_is_total?
    before_action :set_position, only: [:show, :edit, :update, :destroy, :commits_compound_spark]
    before_action :redirect_to_contribution_if_found, only: :show, unless: :params_id_is_total?
    before_action :account_context
    before_action :set_project_and_name, only: :one_click_create
    skip_before_action :store_location, only: [:commits_compound_spark]

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

    helper_method :params_id_is_total?
  end

  private

  def set_account
    @account = Account.from_param(params[:account_id]).take
    fail ParamRecordNotFound unless @account
  end

  def redirect_to_languages
    redirect_to account_languages_path(@account)
  end

  def set_position
    @position = @account.positions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise ParamRecordNotFound
  end

  def set_project_and_name
    @project = Project.where(name: params[:project_name]).not_deleted.take
    @name = Name.where(name: params[:committer_name]).take
    fail ParamRecordNotFound unless @project && @name
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

end
