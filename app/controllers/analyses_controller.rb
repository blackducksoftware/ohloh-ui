class AnalysesController < ApplicationController
  helper :Projects

  before_action :set_project
  before_action :set_analysis, except: :licenses
  before_action :fail_if_analysis_not_found, except: :lanaguages_summary
  before_action :project_context, only: :languages_summary

  def show
    respond_to do |format|
      format.html { redirect_to project_path(@project) }
      format.xml { @status = @analysis.blank? ? 404 : 200 }
    end
  end

  def languages_summary
    @analysis ||= @project.best_analysis
    @language_breakdown = Analysis::LanguageBreakdown.new(analysis: @analysis).collection
  end

  def licenses
    @licenses = Analysis.license_counts(params[:id])
  end

  def top_commit_volume_chart
    top_commit_volume_chart = Analysis::TopCommitVolumeChart.new(@analysis).data
    render json: top_commit_volume_chart
  end

  def commits_history
    commits_history = Analysis::CommitHistoryChart.new(@analysis).data
    render json: commits_history
  end

  def committer_history
    committer_history = Analysis::ContributorHistoryChart.new(@analysis).data
    render json: committer_history
  end

  def language_history
    language_history = Analysis::LanguageHistoryChart.new(@analysis).data
    render json: language_history
  end

  def code_history
    code_history = Analysis::CodeHistoryChart.new(@analysis).data
    render json: code_history
  end

  def lines_of_code
    lines_of_code = Analysis::CodeHistoryChart.new(@analysis).data_for_lines_of_code
    render json: lines_of_code
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
