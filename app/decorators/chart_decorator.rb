# frozen_string_literal: true

class ChartDecorator
  # rubocop:disable Metrics/AbcSize
  def combined_commit_history(account)
    report_data = CommitsByProject.new(account).chart_data
    chart = CHART_DEFAULTS.clone

    chart.deep_merge! YAML.safe_load(ERB.new(Rails.root.join('config', 'charting',
                                                             'combined_commit_history.yml').read).result(binding))
    chart[:yAxis][:max] = report_data[:max_commits]
    chart[:xAxis][:categories] = string_to_hash(report_data[:x_axis])
    chart[:series] = [{ name: I18n.t('all_projects'), data: report_data[:y_axis] }]
    chart[:noCommits] = true if report_data[:max_commits].to_i.zero?

    chart.to_json
  end

  # Unable to reduce further without passing data around.
  # rubocop:disable Metrics/MethodLength
  def project_commit_history(account, project_id)
    report_data = CommitsByProject.new(account).chart_data(project_id)
    chart = build_chart_with_background_style_and_commit_history

    y_axis_min_point = -0.03 * report_data[:max_commits].to_f
    chart[:plotOptions][:column][:threshold] = y_axis_min_point
    chart[:yAxis][:min] = y_axis_min_point
    chart[:yAxis][:max] = report_data[:max_commits]
    chart[:xAxis][:categories] = string_to_hash(report_data[:x_axis])
    chart[:series] = [{ data: report_data[:y_axis] }]
    chart[:noCommits] = true if report_data[:max_commits].to_i.zero?
    chart[:legend] = { enabled: false }

    chart.to_json
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # image_name is used in erb binding.
  def background_style(image_name)
    file_contents = Rails.root.join('config', 'charting', 'chart_background_style.yml.erb').read
    parsed_contents = ERB.new(file_contents).result(binding)
    YAML.safe_load(parsed_contents)
  end

  def string_to_hash(stringified_dates)
    stringified_dates.map do |date_string|
      { commit_month: date_string,
        stringify: date_string =~ /Jan/ ? date_string.split('-').last : '' }
    end
  end

  private

  def build_chart_with_background_style_and_commit_history
    chart = CHART_DEFAULTS.clone

    chart.deep_merge!(background_style('watermark_white_900'))
    chart.deep_merge! YAML.load_file Rails.root.join('config', 'charting', 'project_commit_history.yml')
  end
end
