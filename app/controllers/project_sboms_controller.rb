# frozen_string_literal: true

class ProjectSbomsController < ApplicationController
  helper ProjectsHelper

  before_action :set_project_or_fail

  def index
    @agent = @project.sboms.pluck(:agent)
  end
end
