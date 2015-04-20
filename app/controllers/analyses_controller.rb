class AnalysesController < ApplicationController
  before_action :set_project
  before_action :set_analysis, except: :licenses
  before_action :fail_if_analysis_not_found, except: :lanaguages_summary
  before_action :code_context, only: :languages_summary

  def show
    redirect_to project_path(@project)
  end

  def lanaguages_summary
    @analysis ||= @project.best_analysis
    @langauge_breakdown = Analysis::LanguageBreakdown.new(analysis: @analysis).collection
  end

  def languages
    modified_params.reverse_merge(width: '154', height: '154', border: 1, show: true)
    languages = @analysis.language_percentages(modified_params).map { |_, name, value| [name, value] }
    chart_format = Chart::Format.new(width: params[:width].to_i, height: params[:height].to_i,
                                     p_legend_height: 40, right_buffer: 40)
    chart = Chart::Pie.render(chart_format, languages, params)
    send_file chart, disposition: 'inline', type: 'image/png'
  end

  def licenses
    @licenses = Analysis.license_counts(params[:id])
  end

  def commit_volume_chart
    render json: @analysis.commit_volume_chart
  end

  def top_commit_volume_chart
    render json: @analysis.top_commit_volume_chart
  end

  def commits_history
    render json: @analysis.commits_history_chart
  end

  def committer_history
    render json: @analysis.committer_history_chart
  end

  def language_history
    render json: @analysis.language_history_chart
  end

  def code_history
    render json: @analysis.code_history_chart(params[:chart_size])
  end

  def commits_spark
    monthly_commits = Analysis::MonthlyCommits.new(analysis: @analysis).execute
    spark_image = Spark::SimpleSpark.new(monthly_commits, max_value: 5000).render.to_blob
    send_data spark_image, type: 'image/png', filename: 'commits.png', disposition: 'inline'
  end

  private

  def set_project
    @project = Project.active.from_param(params[:project_id]).take
    fail ParamRecordNotFound unless @project
  end

  def set_analysis
    @analysis = params[:id] == 'latest' ? @project.best_analysis : Analysis.where(id: params[:id]).take
  end

  def fail_if_analysis_not_found
    fail ParamRecordNotFound if @analysis.blank?
  end
end
