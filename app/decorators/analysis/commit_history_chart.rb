class Analysis::CommitHistoryChart < Analysis::Chart
  def intitialize(analysis)
    @analysis = analysis
    @history = Analysis::CommitHistory.new(analysis)
    @defaults = ANALYSIS_CHART_DEFAULTS.deep_merge(COMMIT_HISTORY_CHART_DEFAULTS)
  end

  private

  def series_data_map
    [series_data_without_axis_data, x_and_y_axis_data]
  end

  def series_data_without_axis_data
    series.reject_if { |data| data['month'] < latest_date }.map { |h| [h['ticks'], h['commits'].to_i] }
  end

  def x_and_y_axis_data
    [{ 'x' => series.last['ticks'], 'y' => series.last['commits'].to_i }]
  end
end
