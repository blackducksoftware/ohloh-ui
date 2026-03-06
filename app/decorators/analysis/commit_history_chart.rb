# frozen_string_literal: true

class Analysis::CommitHistoryChart < Analysis::Chart
  def initialize(analysis)
    super()
    @analysis = analysis
    @history = Analysis::CommitHistory.new(analysis: analysis).execute
    @defaults = ANALYSIS_CHART_DEFAULTS.deep_merge(ANALYSIS_CHARTS_OPTIONS['commits_history'])
  end

  def data
    chart_data = series_and_range_data(@defaults)
      .deep_merge(ANALYSIS_CHARTS_OPTIONS['commits_history_auxillaries'])
      .deep_merge(chart_watermark)

    apply_commits_palette(chart_data)
  end

  private

  def series_data_map
    [series_data_without_axis_data, x_and_y_axis_data]
  end

  def series_data_without_axis_data
    series.select { |data| data.month < latest_date }.map { |h| [h.ticks, h.commits] }
  end

  def x_and_y_axis_data
    return [] unless series.last

    [{ 'x' => series.last.ticks, 'y' => series.last.commits }]
  end

  def apply_commits_palette(chart_data)
    series_config = chart_data[:series] || []
    series_config[0][:color] = '#2f7ed8' if series_config[0]
    series_config[1][:color] = '#2f7ed8' if series_config[1]
    chart_data
  end
end
