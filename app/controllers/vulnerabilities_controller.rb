class VulnerabilitiesController < ApplicationController
  helper VulnerabilitiesHelper
  before_action :set_project_or_fail
  before_action :set_best_project_security_set
  before_action :create_release_data, only: [:index]
  before_action :set_releases, only: [:version_chart]

  def index
    gon.releases = @release_data
  end

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

  def create_release_data
    @release_data = []
    all_releases = @best_project_security_set.releases.order(released_on: :asc)
    all_releases.each do |r|
      @release_data << { version: r.version, released_on: r.released_on,
                        high_vulns: r.vulnerabilities.high.count,
                        medium_vulns: r.vulnerabilities.medium.count,
                        low_vulns: r.vulnerabilities.low.count }
    end
  end
end
