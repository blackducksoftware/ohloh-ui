class VulnerabilitiesController < ApplicationController
  layout 'responsive_project_layout', only: [:index]
  helper VulnerabilitiesHelper
  before_action :set_project_or_fail
  before_action :set_best_project_security_set
  before_action :set_vulnerabilities, only: [:index]
  before_action :all_releases, only: [:all_version_chart, :index]
  before_action :recent_releases, only: [:recent_version_chart]

  def all_version_chart
    render json: Vulnerability::AllVersionChart.new(@releases).data
  end

  def recent_version_chart
    render json: Vulnerability::RecentVersionChart.new(@releases).data
  end

  private

  def set_best_project_security_set
    @best_project_security_set = @project.best_project_security_set
  end

  def set_vulnerabilities
    @vulnerabilites = @best_project_security_set.vulnerabilities_by_cve.paginate(page: page_param, per_page: 10) if @best_project_security_set
  end

  def recent_releases
    @releases = @best_project_security_set.most_recent_releases
  end

  def all_releases
    return unless @best_project_security_set
    @releases = @best_project_security_set.all_releases
  end
end
