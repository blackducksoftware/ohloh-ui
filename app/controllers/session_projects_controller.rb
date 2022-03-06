# frozen_string_literal: true

class SessionProjectsController < ApplicationController
  skip_before_action :store_location
  before_action :prevent_bot_access
  before_action :set_project, only: :create
  before_action :set_session_projects

  def index
    render partial: 'menu'
  end

  def create
    if @session_projects.size < 3
      @session_projects.push(@project).uniq!
      session[:session_projects] = @session_projects.map(&:to_param)
      render partial: 'menu'
    else
      render plain: t('.limit_exceeded'), status: :forbidden
    end
  end

  def destroy
    @session_projects.delete_if { |project| project.to_param == params[:id] }
    session[:session_projects] = @session_projects.map(&:to_param)
    render partial: 'menu'
  end

  protected

  def prevent_bot_access
    render plain: '', status: :forbidden if bot?
  end

  def set_project
    @project = Project.from_param(params[:project_id]).take
    raise ActiveRecord::RecordNotFound unless @project
  end
end
