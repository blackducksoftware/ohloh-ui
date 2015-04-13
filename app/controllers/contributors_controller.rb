class ContributorsController < ApplicationController
  helper MapHelper

  before_action :find_project, only: [:near]

  def near
    render text: view_context.map_near_contributors_json(@project, params)
  end

  private

  def find_project
    @project = Project.from_param(params[:project_id]).take
    fail ParamRecordNotFound unless @project
  end
end
