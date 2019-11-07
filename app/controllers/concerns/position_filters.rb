# frozen_string_literal: true

module PositionFilters
  extend ActiveSupport::Concern

  included do
    before_action :session_required, :redirect_unverified_account,
                  only: %i[edit new create delete one_click_create]
    before_action :set_account
    before_action :must_own_account, only: %i[edit update new create one_click_create]
    before_action :redirect_to_languages, only: :show, if: :params_id_is_total?
    before_action :set_position, only: %i[show edit update destroy commits_compound_spark]
    before_action :redirect_to_contribution_if_found, only: :show, unless: :params_id_is_total?
    before_action :account_context
    before_action :set_project_and_name, only: :one_click_create
    before_action :set_project_and_name_fact, only: :commits_compound_spark
    skip_before_action :store_location, only: [:commits_compound_spark]
    helper_method :params_id_is_total?
  end

  def create; end

  def new; end

  def show; end

  def edit; end

  def udpate; end

  def delete; end

  def destroy; end

  private

  def set_account
    @account = Account.from_param(params[:account_id]).take
    raise ParamRecordNotFound unless @account
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
    raise ParamRecordNotFound unless @project && @name
  end

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def set_project_and_name_fact
    @project = @position.project
    @name_fact = ContributorFact.includes(:name).where(analysis_id: @project.best_analysis_id,
                                                       name_id: @position.name_id).first
  end
end
