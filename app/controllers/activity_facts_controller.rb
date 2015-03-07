class ActivityFactsController < ApplicationController
  include ApiKeyChecks

  before_action :set_project
  before_action :verify_api_key

  def index
    if params[:analysis_id] == 'latest'
      @analysis = @project.best_analysis
    else
      @analysis = Analysis.find(params[:analysis_id])
    end

    @activity_facts = ActivityFactByMonth.new(@analysis).result
  end

  private

  def set_project
    @project = Project.from_param(params[:project_id]).first
    render 'projects/deleted' if @project.deleted?
  end
end
