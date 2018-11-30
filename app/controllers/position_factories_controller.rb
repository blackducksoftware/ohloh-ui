class PositionFactoriesController < ApplicationController
  before_action :session_required, :redirect_unverified_account
  before_action :set_account
  before_action :must_own_account

  before_action :load_project_by_project_name
  before_action :check_for_project_existence
  before_action :load_name_by_committer_name
  before_action :check_for_committer_existence
  before_action :claim_existing_position_or_create_alias

  def create
    # Render new position form to allow users to fill in the affiliation.
    flash[:success] = t('.success', name: CGI.escapeHTML(@name.name))
    redirect_to new_account_position_path(@account, project_name: @project.name,
                                                    committer_name: @name.name,
                                                    invite: params[:invite])
  end

  private

  def set_account
    @account = Account.resolve_login(params[:account_id])
    raise ParamRecordNotFound unless @account
  end

  def load_project_by_project_name
    @project = Project.active.find_by(name: params[:project_name])
  end

  def check_for_project_existence
    return if @project
    flash[:error] = t('.project_not_found', name: CGI.escapeHTML(params[:project_name].to_s))
    redirect_to projects_path
  end

  def load_name_by_committer_name
    @name = Name.find_by(name: params[:committer_name])
  end

  def check_for_committer_existence
    return if @name
    flash[:error] = t('.contributor_not_found', name: CGI.escapeHTML(params[:committer_name].to_s))
    redirect_to project_contributors_path(@project)
  end

  # rubocop:disable Metrics/AbcSize
  def claim_existing_position_or_create_alias
    result = @account.position_core.ensure_position_or_alias!(@project, @name)
    return unless result

    if result.is_a?(Alias)
      flash[:success] = t('.rename_commit_author',
                          name: CGI.escapeHTML(@name.name),
                          preferred_name: CGI.escapeHTML(result.preferred_name.name))
    end
    flash[:success] = t('contribution_claimed', name: CGI.escapeHTML(@name.name)) if result.is_a?(Position)

    redirect_to account_positions_path(@account)
  end
  # rubocop:enable Metrics/AbcSize
end
