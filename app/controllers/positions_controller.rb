class PositionsController < ApplicationController
  helper ProjectsHelper
  helper PositionsHelper
  before_action :session_required, only: [:edit, :new, :create, :delete]
  before_action :set_account
  before_action :must_own_account, only: [:edit, :update, :new, :create]
  before_action :redirect_to_languages, only: :show, if: :params_id_is_total?
  before_action :set_position, only: [:show, :edit, :update, :destroy, :commits_compound_spark]
  before_action :redirect_to_contribution_if_found, only: :show, unless: :params_id_is_total?
  before_action :account_context

  helper_method :params_id_is_total?

  def new
    # When someone 'claims' to be a committer, we get some params prepopulated.
    @position = Position.new(committer_name: params[:committer_name],
                             project_oss: params[:project_name])
  end

  def update
    Position.transaction do
      @position.language_experiences.delete_all
      @position.update!(position_params)
    end

    redirect_to account_positions_path(@account)
  rescue => e
    flash.now[:error] = e.message unless e.is_a?(ActiveRecord::RecordInvalid)
    render :edit
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @position = @account.positions.new(position_params)
    if @position.save
      if params[:invite].present? && @account.created_at > 1.day.ago
        flash[:success] = t('.invite_success')
      end

      redirect_to account_positions_path(@account)
    else
      render :new
    end
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    if @position.destroy
      redirect_to account_positions_path, notice: t('destroy.success')
    else
      redirect_to :back, flash: { error: t('destroy.failure') }
    end
  end

  def index
    @positions = @account.position_core.ordered
  end

  def commits_compound_spark
    @project = @position.project
    @name_fact = ContributorFact.includes(:name).where("analysis_id = '#{@project.best_analysis_id}'
      AND name_id = '#{@position.name_id}'").first
    spark_image = Spark::CompoundSpark.new(@name_fact.monthly_commits(11), max_value: 50).render.to_blob
    send_data spark_image, type: 'image/png', filename: 'position_commits_compound_spark.png', disposition: 'inline'
  end

  private

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def params_id_is_total?
    params[:id].to_s.downcase == 'total'
  end

  def set_position
    @position = @account.positions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise ParamRecordNotFound
  end

  def set_account
    @account = Account.from_param(params[:account_id]).take
    fail ParamRecordNotFound unless @account
  end

  def position_params
    params.require(:position)
      .permit(:project_oss, :committer_name, :title, :organization_id, :organization_name,
              :affiliation_type, :description, :start_date, :stop_date, :ongoing, :invite,
              language_exp: [], project_experiences_attributes: [:project_name, :_destroy, :id])
  end

  def redirect_to_languages
    redirect_to account_languages_path(@account)
  end
end
