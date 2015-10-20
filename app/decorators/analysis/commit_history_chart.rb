class Analysis::CommitHistoryChart < Analysis::Chart
  def initialize(analysis)
    @analysis = analysis
    @history = Analysis::MonthlyCommitHistory.new(analysis: analysis).execute
    @defaults = ANALYSIS_CHART_DEFAULTS.deep_merge(ANALYSIS_CHARTS_OPTIONS['commits_history'])
  end

  def data
    series_and_range_data(@defaults)
      .deep_merge(ANALYSIS_CHARTS_OPTIONS['commits_history_auxillaries'])
      .deep_merge(chart_watermark)
  end

  private

  def series_data_map
    [series_data_without_axis_data, x_and_y_axis_data]
  end

  def series_data_without_axis_data
    series.select { |data| data[:month] < latest_date }.map { |h| [h[:ticks], h[:count].to_i] }
  end

  def x_and_y_axis_data
    [{ 'x' => series.last[:ticks], 'y' => series.last[:count].to_i }]
  end

  def first_ticks
    series.first[:ticks]
  end

  def series
    @series ||= history_with_ticks.drop_while { |hsh| hsh[:ticks] < min_month_as_ticks }
  end

  def history_with_ticks
    history_with_month.each { |hsh| hsh[:ticks] = hsh[:month].to_i * 1000 }
  end

  def history_with_month
    @history.each { |hsh| hsh[:month] =  "#{ hsh[:this_month] } UTC".to_time }
  end
end
