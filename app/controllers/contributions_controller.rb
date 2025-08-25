# frozen_string_literal: true

class ContributionsController < ApplicationController
  COMMITS_SPARK_IMAGE = 'app/assets/images/bot_stuff/contribution_commits_spark.png'
  COMMITS_COMPOUND_SPARK_IMAGE = 'app/assets/images/bot_stuff/position_commits_compound_spark.png'

  helper :kudos, :projects
  helper MapHelper

  before_action :set_project_or_fail, if: -> { params[:project_id] }
  before_action :set_contribution, except: %i[commits_spark commits_compound_spark index summary near]
  before_action :set_contributor, only: %i[commits_spark commits_compound_spark]
  before_action :send_sample_image_if_bot, if: :bot?, only: %i[commits_spark commits_compound_spark]
  before_action :project_context, only: %i[index show summary]
  skip_before_action :store_location, only: %i[commits_spark commits_compound_spark]

  def index
    raise ParamRecordNotFound unless @project

    @contributions = @project.contributions_within_timespan(params).paginate(per_page: 20, page: page_param)
  end

  def show
    raise ParamRecordNotFound unless @project
    return redirect_to project_contributor_path(@project, @contribution) if @contribution.id != params[:id].to_i

    @recent_kudos = @contribution.kudoable.recent_kudos || []
  end

  def summary
    @newest_contributions = @project.newest_contributions
    @top_contributions = @project.top_contributions
    @analysis = @project.best_analysis
  end

  def near
    render plain: view_context.map_near_contributors_json(@project, params)
  end

  def commits_spark
    spark_image = Rails.cache.fetch("contributor/#{@contributor.id}/commits_spark", expires_in: 4.hours) do
      Spark::SimpleSpark.new(@contributor.monthly_commits, max_value: 50).render.to_blob
    end
    send_data spark_image, type: 'image/png', filename: 'commits.png', disposition: 'inline'
  end

  def commits_compound_spark
    spark_image = Rails.cache.fetch("contributor/#{@contributor.id}/commits_compound_spark", expires_in: 4.hours) do
      Spark::CompoundSpark.new(@contributor.monthly_commits(11), max_value: 50).render.to_blob
    end
    send_data spark_image, type: 'image/png', filename: 'commits.png', disposition: 'inline'
  end

  private

  def set_contributor
    id = params[:id].to_i
    @contributor = Contribution.find(id).name_fact if id > (1 << 32)
    @contributor ||= ContributorFact.joins(:name).where(names: { id: id })
                                    .find_by(analysis_id: @project.best_analysis_id)
    raise ParamRecordNotFound unless @contributor
  end

  def send_sample_image_if_bot
    image_path = Rails.root.join(self.class.const_get("#{action_name.upcase}_IMAGE"))
    send_file image_path, filename: 'commits.png', type: 'image/png', disposition: 'inline'
  end

  def set_contribution
    raise ParamRecordNotFound unless @project

    @contribution = @project.contributions.find_by(id: params[:id].to_i)
    # It's possible that the contributor we are looking for has been aliased to a new name.
    # Redirect to the new name if we can find it.
    @contribution ||= Contribution.find_indirectly(contribution_id: params[:id].to_i, project: @project)
    raise ParamRecordNotFound unless @contribution
  end
end
