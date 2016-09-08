class VulnerabilitiesController < ApplicationController
  before_action :set_project_or_fail
  before_action :set_best_project_security_set
  before_action :set_releases

  def version_chart
    render json: Vulnerability::VersionChart.new(@releases).data
  end

  private

  def set_best_project_security_set
    @best_project_security_set = @project.best_project_security_set
  end

  def set_releases
    @releases = @best_project_security_set.most_recent_releases
  end
end
