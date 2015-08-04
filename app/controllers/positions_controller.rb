class PositionsController < ApplicationController
  helper ProjectsHelper
  helper PositionsHelper
  before_action :session_required, only: [:edit, :new, :create, :delete, :one_click_create]
  before_action :set_account, except: :one_click_create
  before_action :must_own_account, only: [:edit, :update, :new, :create]
  before_action :redirect_to_languages, only: :show, if: :params_id_is_total?
  before_action :set_position, only: [:show, :edit, :update, :destroy, :commits_compound_spark]
  before_action :redirect_to_contribution_if_found, only: :show, unless: :params_id_is_total?
  before_action :account_context
  before_action :set_project_and_name, only: :one_click_create
  skip_before_action :store_location, only: [:commits_compound_spark]

  helper_method :params_id_is_total?

  def new
    @position = Position.new
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
    @name_fact = ContributorFact.includes(:name).where(analysis_id: @project.best_analysis_id,
                                                       name_id: @position.name_id).first
    spark_image = Spark::CompoundSpark.new(@name_fact.monthly_commits(11), max_value: 50).render.to_blob
    send_data spark_image, type: 'image/png', filename: 'position_commits_compound_spark.png', disposition: 'inline'
  end

  def one_click_create
    pos_or_alias_obj = current_user.position_core.ensure_position_or_alias!(@project, @name)
    return redirect_to_new_position_path unless pos_or_alias_obj

    if pos_or_alias_obj.is_a?(Alias)
      flash_msg = t('.alias', name: @name.name, preferred_name: pos_or_alias_obj.preferred_name.name)
    else
      flash_msg = t('.position', name: @name.name)
    end

    redirect_to account_positions_path(current_user), flash: { success: flash_msg }
  end

  private

  def redirect_to_contribution_if_found
    project = @position.project
    return unless project && !project.deleted && @position.contribution

    redirect_to project_contributor_path(project, @position.contribution)
  end

  def redirect_to_new_position_path
    redirect_to new_account_position_path(current_user, committer_name: @name.name,
                                                        project_name: @project.name, invite: params[:invite]),
                flash: { success: t('positions.one_click_create.new_position', name: @name.name) }
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

  def set_project_and_name
    @project = Project.where(name: params[:project_name]).not_deleted.take
    @name = Name.where(name: params[:committer_name]).take
    fail ParamRecordNotFound unless @project && @name
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
