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

  def sort_col_param
    params.fetch(:sort, {})[:col]
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

  def sort_columns
    %w(cve_id severity published_on)
  end

  def current_sort_column_and_order
    col = sort_columns.include?(sort_col_param) ? sort_col_param : sort_columns[0]
    direction = sort_col_param.present? ? params[:sort][:direction] : 'desc'
    [col, direction]
  end

  def render_sort_icon(col)
    asc_icon, desc_icon = sort_icon_visibility_classes(col)
    content_tag :span do
      content_tag :btn, id: "sort_#{col}", class: 'vulnerability_sort_btn', data: { source: col } do
        concat content_tag(:i, nil, class: "fa fa-sort-amount-asc #{asc_icon}", data: { direction: 'asc' })
        concat content_tag(:i, nil, class: "fa fa-sort-amount-desc #{desc_icon}", data: { direction: 'desc' })
      end
    end
  end

  def sort_icon_visibility_classes(col)
    current_col, current_direction = current_sort_column_and_order
    asc_desc_icon = %w(disable hidden)
    if col == current_col
      asc_desc_icon = current_direction == 'desc' ? ['hidden', ''] : ['', 'hidden']
    end
    asc_desc_icon
  end
end
