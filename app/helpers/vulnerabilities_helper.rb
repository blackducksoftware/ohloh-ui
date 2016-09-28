module VulnerabilitiesHelper
  def filter_severity_param
    return nil unless Vulnerability.severity_exists?(params.fetch(:filter, {})[:severity])
    params[:filter][:severity]
  end

  def filter_version_param
    params.fetch(:filter, {})[:version]
  end

  def filter_major_version_param
    params.fetch(:filter, {})[:major_version]
  end

  def filter_period_param
    params.fetch(:filter, {})[:period]
  end

  def best_security_set_releases
    return [] unless @project.best_project_security_set
    @project.best_project_security_set.releases.sort_by_release_date
  end

  def no_versions_available
    [Release.new(id: '', version: t('vulnerabilities.filter.no_versions_available'))]
  end

  def disabled_severities
    return [] unless @latest_version
    severities.select { |s| @latest_version.vulnerabilities.send(s).empty? }
  end

  def options_for_severities_filter
    options_for_select(severities.collect { |s| [s.capitalize, s] },
                       selected: filter_severity_param, disabled: disabled_severities)
  end

  def severities
    Vulnerability.severities.keys
  end
end
