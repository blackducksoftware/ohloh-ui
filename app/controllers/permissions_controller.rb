class PermissionsController < ApplicationController
  before_action :session_required
  before_action :find_model

  def show
  end

  def update
  end

  private

  def find_model
    @model = current_project.permission || Permission.new(target: current_project)
  end
end
