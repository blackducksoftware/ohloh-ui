# frozen_string_literal: true

class ProjectSbomsController < ApplicationController
  helper ProjectsHelper

  before_action :find_project

  def index
    @project_sbom = @project.project_sboms&.first if @project
    respond_to do |format|
      format.js
    end
  end

  private

  def find_project
    return nil unless params[:project_id]

    @project = Project.by_vanity_url_or_id(params[:project_id]).take
  end
end
