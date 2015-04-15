class Analysis::CodeHistoryChart < Analysis::Chart
  def initialize(analysis)
    @analysis = analysis
    @history = Analysis::CodeHistory.new(analysis)
    @defaults = ANALYSIS_CHART_DEFAULTS.deep_merge(CODE_HISTORY_CHART_DEFAULTS)
  end

  private

  def series_data
    [code_total_series, comment_total_series, blank_total_series]
  end

  def code_total_series
    series.map { |h| [ h['ticks'], h['code_total'].to_i ] }
  end

  def comment_total_series
    series.map { |h| [ h['ticks'], h['comment_total'].to_i ] }
  end

  def blank_total_series
    series.map { |h| [ h['ticks'], h['blank_total'].to_i ] }
  end
end
