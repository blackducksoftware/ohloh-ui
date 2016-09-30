module VulnerabilitiesHelper
  def major_releases(releases)
    releases.map do |r|
      r[:version].scan(/^\d+/)
    end.flatten.uniq.sort
  end

  def map_vulnerabilities_to_releases(releases)
    data = []
    releases.each do |r|
      data << { id: r.id,
                version: r.version,
                released_on: r.released_on,
                high_vulns: r.vulnerabilities.high,
                medium_vulns: r.vulnerabilities.medium,
                low_vulns: r.vulnerabilities.low }
    end
    data
  end

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
    [Release.new(id: '', version: t('.vulnerabilities.filter.no_versions_available'))]
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

  def release_timespan_widget
    html = ''
    timespan = releaase_timespan_options
    timespan.each do |label, options|
      html << content_tag(:div, label,
                          class: "btn btn-info btn-mini release_timespan #{(options[1..2] || []).join(' ')}".strip,
                          date: options[0])
    end
    html << hidden_field_tag('vulnerability_filter_period', filter_period_param, class: 'vulnerability_main_filter')
    html.html_safe
  end

  def releaase_timespan_options
    timespan = {}
    Release::TIMESPAN.each { |label, values| timespan[label] = values.dup }
    disable_timespan(timespan)
    set_default_timespan(timespan)
  end

  def set_default_timespan(timespan)
    timespan.tap { |ts| ts[@default_timespan].push 'selected' }
  end

  def disable_timespan(timespan)
    timespan.each do |_label, values|
      next if values[0].blank?
      values.push(@best_security_set.releases.select_within_years(values[0]).blank? ? 'disabled' : '')
    end
  end
end
