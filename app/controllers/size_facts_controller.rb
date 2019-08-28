# frozen_string_literal: true

class SizeFactsController < ApplicationController
  helper :projects

  before_action :set_project_or_fail

  LATEST_ID = 'latest'

  def index
    latest_analysis = params[:analysis_id] == LATEST_ID
    @analysis = latest_analysis ? @project.best_analysis : Analysis.find(params[:analysis_id])
    @size_facts = Analysis::CodeFacts.new(analysis: @analysis).execute
  end
end
