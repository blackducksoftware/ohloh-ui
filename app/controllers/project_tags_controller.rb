class ProjectTagsController < ApplicationController
  helper ProjectsHelper
  helper TagsHelper

  before_action :find_project
  before_action :find_related_projects, only: [:index, :related]
  before_action :project_context

  def create
  end

  def destroy
  end

  def related
  end

  def status
  end

  private

  def find_project
    @project = Project.from_param(params[:project_id]).take
    fail ParamRecordNotFound if @project.nil?
    @project.editor_account = current_user
  end

  def find_related_projects
    @related_projects = @project.related_by_tags
  end
end
