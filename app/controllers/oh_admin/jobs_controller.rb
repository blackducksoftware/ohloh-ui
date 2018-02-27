class OhAdmin::JobsController < ApplicationController
  before_action :admin_session_required
  before_action :find_project
  layout 'admin'
  helper JobApiHelper

  def index
    @response = JSON.parse(JobApi.new(id: @project.id, page: params[:page] || 1).fetch)
  end

  private

  def find_project
    @project = Project.find_by_vanity_url(params[:project_id])
    raise ParamRecordNotFound if @project.nil?
  end
end
