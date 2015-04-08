class ContributionsController < ApplicationController
  COMMITS_SPARK_IMAGE = 'app/assets/images/bot_stuff/contribution_commits_spark.png'
  COMMITS_COMPOUND_SPARK_IMAGE = 'app/assets/images/bot_stuff/position_commits_compound_spark.png'

  helper :kudos, :projects
  helper MapHelper

  before_action :set_project
  before_action :set_contribution, except: [:commits_spark, :commits_compound_spark, :index, :summary, :near]
  before_action :set_contributor, only: [:commits_spark, :commits_compound_spark]
  before_action :send_sample_image_if_bot, if: :bot?, only: [:commits_spark, :commits_compound_spark]
  before_action :project_context, only: [:index, :show, :summary]

  def index
    @contributions = @project.contributions
                     .sort(params[:sort])
                     .filter_by(params[:query])
                     .includes(person: :account, contributor_fact: :primary_language)
                     .references(:all)
                     .paginate(per_page: 20, page: params[:page])
  end

  def show
    redirect_to project_contributor_path(@project, @contribution) && return if @contribution.id != params[:id].to_i
    account = @contribution.person.account
    if account
      @recent_kudos = account.kudos.order(created_at: :desc).limit(3)
    else
      @recent_kudos = @contribution.recent_kudos
    end
  end

  def summary
    @newest_contributions = @project.newest_contributions
    @top_contributions = @project.top_contributions
    @analysis = @project.best_analysis
  end

  def near
    render text: view_context.map_near_contributors_json(@project, params)
  end

  def commits_spark
    spark_image = Spark::SimpleSpark.new(@contributor.monthly_commits, max_value: 50).render
    send_file spark_image.path, type: 'image/png', filename: 'commits.png', disposition: 'inline'
  end

  def commits_compound_spark
    spark_image = Spark::CompoundSpark.new(@contributor.monthly_commits(11), max_value: 50).render
    send_file spark_image.path, type: 'image/png', filename: 'commits.png', disposition: 'inline'
  end

  private

  def set_contributor
    @contributor = ContributorFact.where(names: { id: params[:id] }).where(analysis_id: @project.best_analysis_id)
                   .eager_load(:name).first
  end

  def send_sample_image_if_bot
    image_path = "#{Rails.root}/#{Object.const_get(action_name.upcase + '_IMAGE')}"
    send_file image_path, filename: 'commits.png', type: 'image/png', disposition: 'inline'
  end

  def set_contribution
    @contribution = @project.contributions.find_by(id: params[:id].to_i)
    # It's possible that the contributor we are looking for has been aliased to a new name.
    # Redirect to the new name if we can find it.
    @contribution ||= Contribution.find_indirectly(contribution_id: params[:id].to_i, project: @project)
    fail ParamRecordNotFound unless @contribution
  end

  def set_project
    @project = Project.not_deleted.from_param(params[:project_id]).take
    render 'projects/deleted' if @project.deleted?
  end
end
