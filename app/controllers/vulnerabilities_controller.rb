class VulnerabilitiesController < ApplicationController
  before_action :set_project_or_fail
  before_action :set_best_project_security_set
  before_action :set_releases
  before_action :set_vulnerabilities

  def vulnerabilities_per_version
    @release_versions = @releases.map(&:version).to_json
  end

  private

  def set_project_or_fail
    project_id = params[:project_id] || params[:id]
    @project = Project.by_vanity_url_or_id(project_id).take
    raise ParamRecordNotFound unless @project
  end

  def set_best_project_security_set
    @best_project_security_set = @project.best_project_security_set
  end

  def set_releases
    @releases = @best_project_security_set.releases.order(released_on: :asc).limit(10)
  end

  # rubocop:disable Metrics/AbcSize
  def set_vulnerabilities
    @vulnerabilities = Array.new(3) { [] }
    @releases.each do |r|
      @vulnerabilities[0] << r.vulnerabilities.low.count
      @vulnerabilities[1] << r.vulnerabilities.medium.count
      @vulnerabilities[2] << r.vulnerabilities.high.count
    end
  end
  # rubocop:enable Metrics/AbcSize
end
