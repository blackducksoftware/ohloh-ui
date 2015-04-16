class AnalysesController < ApplicationController
  before_action :set_project
  before_filter :set_analysis, except: [:licenses]

  def show
    redirect_to project_path(@project)
  end

  def languages_summary
    @analysis ||= @project.best_analysis
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

  def commitshistory
    render json: @analysis.commits_history_chart
  end

  def committerhistory
    render json: @analysis.committer_history_chart
  end

  def languagehistory
    render json: @analysis.language_history_chart
  end

  def codehistory
    render json: @analysis.code_history_chart(params[:chart_size])
  end

  def commits_spark
    spark_image = NewSpark.new(@analysis.monthly_commits, max_value: 5000).render.to_blob
    send_data spark_image, type: 'image/png', filename: 'commits.png', disposition: 'inline'
  end

  private

  def set_project
    @project = Project.active.from_param(params[:project_id]).take
    fail ParamRecordNotFound unless @project
  end

  def set_analysis
    @analysis = params[:id] == 'latest' ? @project.best_analysis : Analysis.where(id: params[:id]).take
    fail ParamRecordNotFound if @analysis.blank?
  end
end
