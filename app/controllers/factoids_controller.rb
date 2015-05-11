class FactoidsController < ApplicationController
  helper ProjectsHelper

  before_action :find_project
  before_action :find_factoids
  before_action :project_context

  private

  def find_project
    @project = Project.from_param(params[:project_id]).take
    fail ParamRecordNotFound if @project.nil?
  end

  def find_factoids
    @factoids = @project.best_analysis.factoids.reject { |f| f.type.to_s =~ /Distribution|Staff/ }
  end
end
