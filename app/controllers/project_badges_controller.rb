class ProjectBadgesController < ApplicationController
  before_action :set_project_or_fail

  layout 'responsive_project_layout'

  def index
    @badges = ProjectBadge.subclasses.map(&:name)
    @project_badge = ProjectBadge.new
  end
end
