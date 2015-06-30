class SizeFactsController < ApplicationController
  before_action :set_project

  LATEST_ID = 'latest'

  def index
    latest_analysis = params[:analysis_id] == LATEST_ID
    @analysis = latest_analysis ? @project.best_analysis : Analysis.find(params[:analysis_id])
    @size_facts = Analysis::CodeFacts.new(analysis: @analysis).execute
  end

  private

  def set_project
    @project = Project.by_url_name_or_id(params[:project_id]).first
    fail ParamRecordNotFound unless @project
    render 'projects/deleted' if @project.deleted?
  end
end
