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
    @project = Project.deleted_and_not_deleted_from_param(params[:project_id]).first
    fail ParamRecordNotFound if @project.nil?
    render 'projects/deleted' if @project.deleted?
  end
end
