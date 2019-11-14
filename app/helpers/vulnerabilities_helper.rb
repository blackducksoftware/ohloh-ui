# frozen_string_literal: true

# rubocop: disable Metrics/ModuleLength

module VulnerabilitiesHelper
  EMPTY_SEVERITY = 'unknown_severity'

  def major_releases(releases, project)
    # Note: This is a temporary fix for the android project
    if project.vanity_url == 'android'
      releases.map do |r|
        r[:version]
      end
    else
      releases.map do |r|
        r[:version].to_i
      end.flatten.uniq.sort
    end
  end

  def filter_severity_param
    severity = params.fetch(:filter, {})[:severity]
    return nil unless Vulnerability.severity_exists?(severity) || severity == EMPTY_SEVERITY

    severity
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

  def no_versions_available
    [Release.new(id: '', version: t('.vulnerabilities.filter.no_versions_available'))]
  end

  def disabled_severities
    return [] unless @release

    (severities + [EMPTY_SEVERITY]).select { |s| @release.vulnerabilities.send(s).empty? }
  end

  def options_for_severities_filter
    options_for_select(severities.collect { |s| [s.capitalize, s] } + [['Unknown', EMPTY_SEVERITY]],
                       selected: filter_severity_param, disabled: disabled_severities)
  end

  def sort_releases_by_version_number(releases)
    return nil if releases.nil?

    vanity_url = releases.first.project_security_set.project.vanity_url
    if vanity_url == 'android'
      releases.sort { |a, b| b.version <=> a.version }
    else
      releases.sort_by { |release| release_version_to_array(release) }.reverse
    end
  end

  def severities
    Vulnerability.severities.keys
  end

  def release_timespan_widget
    html = ''
    timespan = releaase_timespan_options
    timespan.each do |label, options|
      html += content_tag(:div, label,
                          class: "btn btn-info btn-mini release_timespan #{(options[1..2] || []).join(' ')}".strip,
                          date: options[0])
    end
    html += hidden_field_tag('vulnerability_filter_period', filter_period_param, class: 'vulnerability_main_filter')
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

  def sort_columns
    %w[cve_id severity published_on]
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
    asc_desc_icon = %w[disable hidden]
    if col == current_col
      asc_desc_icon = current_direction == 'desc' ? ['hidden', ''] : ['', 'hidden']
    end
    asc_desc_icon
  end

  private

  def release_version_to_array(release)
    _array = release.version.split('.').map do |token|
      get_release_version_array(token)
    end
  end

  def get_release_version_array(token)
    val = token.to_i
    val.to_s == token ? [val, 0] : get_token_array(token)
  end

  def get_token_array(token)
    if token.include?('-')
      token1, token2 = token.split('-')
      [token1.to_i, get_token_array(token2)].flatten
    else
      get_token_char_array(token)
    end
  end

  # rubocop: disable Metrics/MethodLength
  def get_token_char_array(token)
    case token
    when 'rc'
      [-1]
    when 'beta'
      [-2]
    when 'alpha'
      [-3]
    else
      token.chars.map do |char|
        case char
        when '0'..'9'
          char.to_s.to_i
        when 'A'..'Z', 'a'..'z', '-', '+', '_'
          char.bytes.first.to_i * -1
        end
      end
    end
  end
  # rubocop: enable Metrics/MethodLength
end
# rubocop: enable Metrics/ModuleLength
