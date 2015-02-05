class ProjectsController < ApplicationController
  def autocomplete
    @projects = Project.not_deleted.order('length(projects.name)').limit(25)
    @projects = @projects.where(['(lower(projects.name) like ?)', "%#{params[:term]}%"])
    @projects = @projects.where.not(id: params[:exclude_project_id].to_i) if params[:exclude_project_id].present?
  end
end
