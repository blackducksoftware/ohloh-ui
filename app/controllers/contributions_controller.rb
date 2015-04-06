class ContributionsController < ApplicationController
  COMMITS_SPARK_IMAGE = 'app/assets/images/bot_stuff/contribution_commits_spark.png'
  COMMITS_COMPOUND_SPARK_IMAGE = 'app/assets/images/bot_stuff/position_commits_compound_spark.png'

  helper :kudos, :projects

  before_action :set_project
  before_action :set_contribution, except: [:index, :summary, :near]
  before_action :set_contributor, only: [:commits_spark, :commits_compound_spark]
  before_action :send_sample_image_if_bot, if: :is_bot?, only: [:commits_spark, :commits_compound_spark]
  before_action :project_context, only: [:index, :show]

  def index
    @contributions = @project.contributions.sort(params[:sort])
                      .filter_by(params[:query]).includes(person: :account, contributor_fact: :primary_language)
                      .references(:all).paginate(per_page: 20, page: params[:page] || 1)
  end

  def show
    redirect_to project_contributor_path(@project, @contribution) && return if @contribution.id != params[:id].to_i
    account_or_contribution = @contribution.person.account || @contribution
    @recent_kudos = account_or_contribution.kudos.limit(3)
  end

  def summary
    @newest_contributions = @project.newest_contributions
    @top_contributions = @project.top_contributions
    @analysis = @project.best_analysis
  end

  def commits_spark
    spark_image = SimpleSpark.new(@contributor.monthly_commits, max_value: 50).render
    send_data spark_image, type: 'image/png', filename: 'commits.png', disposition: 'inline'
  end

  def commits_compound_spark
    spark_image = CompoundSpark.new(@contributor.monthly_commits(11), max_value: 50).render
    send_data spark_image, type: 'image/png', filename: 'commits.png', disposition: 'inline'
  end

  def near
    accounts = Account.near(params[:project_id])
    if params[:zoom].to_i < 3
      @accounts = accounts.zoom_out
    else
      @accounts = accounts.zoom_in(params[:lat], params[:lng])
    end

    render json: { accounts: @accounts }
  end

  private

  def set_contributor
    @contributor = ContributorFact.where(id: @contribution.name_fact_id, analysis_id: @project.best_analysis_id)
                    .eager_load(:name).first
  end

  def send_sample_image_if_bot
    image_path = "#{Rails.root}/#{Object.const_get(action_name.upcase + '_IMAGE')}"
    send_file image_path, filename: 'commits.png', type: 'image/png', disposition: 'inline'
  end

  def set_contribution
    @contribution = @project.contributions.where(id: params[:id]).first
    @contribution ||= Contribution.find_indirectly(contribution_id: params[:id], project: @project)
    fail ParamRecordNotFound unless @contribution
  end

  def set_project
    @project = Project.from_param(params[:project_id]).first
    render 'projects/deleted' if @project.deleted?
  end
end
