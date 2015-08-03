class AnalysesController < ApplicationController
  helper :Projects

  before_action :set_project_or_fail
  before_action :set_analysis
  before_action :fail_if_analysis_not_found, except: :languages_summary
  before_action :project_context, only: :languages_summary
  skip_before_action :store_location

  def show
    respond_to do |format|
      format.html { redirect_to project_path(@project) }
      format.xml { @status = @analysis.blank? ? 404 : 200 }
    end
  end

  def languages
    chart_data = Analysis::LanguagePercentages.new(@analysis).collection.map(&:last)
    pie_chart = Chart::Pie.new(chart_data, params[:width], params[:height]).render.to_blob
    send_data pie_chart, disposition: 'inline', type: 'image/png'
  end

  def languages_summary
    @analysis ||= @project.best_analysis
    @languages_breakdown = @analysis.nil? ? [] : Analysis::LanguagesBreakdown.new(analysis: @analysis).collection
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
    committer_history = Analysis::ContributorHistoryChart.new(@analysis).data_without_auxillaries
    render json: committer_history
  end

  def contributor_summary
    contributor_summary = Analysis::ContributorHistoryChart.new(@analysis).data
    render json: contributor_summary
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

  def set_analysis
    @analysis = params[:id] == 'latest' ? @project.best_analysis : Analysis.find_by(id: params[:id])
  end

  def fail_if_analysis_not_found
    fail ParamRecordNotFound if @analysis.blank?
  end
end
