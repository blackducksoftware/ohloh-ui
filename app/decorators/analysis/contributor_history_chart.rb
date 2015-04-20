class Analysis::ContributorHistoryChart < Analysis::Chart
  def initialize(analysis)
    @analysis = analysis
    @history = Analysis::ContributorHistory.new(analysis: analysis).execute
    @defaults = ANALYSIS_CHART_DEFAULTS.deep_merge(COMMITTER_HISTORY_CHART_DEFAULTS)
  end

  private

  def series_data_map
    [series_data_without_axis_data, x_and_y_axis_data]
  end

  def series_data_without_axis_data
    series.reject { |data| data.month < latest_date }.map { |h| [h.ticks, h.contributors] }
  end

  def x_and_y_axis_data
    [{ 'x' => series.last.ticks, 'y' => series.last.contributors }]
  end
end
