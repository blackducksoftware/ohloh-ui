# frozen_string_literal: true

class ActivityFactsController < ApplicationController
  helper :projects

  before_action :set_project_or_fail

  LATEST_ID = 'latest'

  def index
    latest_analysis = params[:analysis_id] == LATEST_ID
    @analysis = latest_analysis ? @project.best_analysis : Analysis.find_by(id: params[:analysis_id])
    @activity_facts = ActivityFactByMonthQuery.new(@analysis).execute if @analysis
  end
end
