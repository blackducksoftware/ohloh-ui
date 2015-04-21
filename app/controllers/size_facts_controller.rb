class SizeFactsController < ApplicationController
  include ApiKeyChecks

  before_action :set_project
  before_action :verify_api_key

  LATEST_ID = 'latest'

  def index
    latest_analysis = params[:analysis_id] == LATEST_ID
    @analysis = latest_analysis ? @project.best_analysis : Analysis.find(params[:analysis_id])
    @size_facts = Analysis::CodeFacts.new(analysis: @analysis).execute
  end

  private

  def set_project
    @project = Project.from_param(params[:project_id]).first
    render 'projects/deleted' if @project.deleted?
  end
end
