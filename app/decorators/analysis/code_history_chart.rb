class Analysis::CodeHistoryChart < Analysis::Chart
  def initialize(analysis)
    @analysis = analysis
    @history = Analysis::CodeHistory.new(analysis: analysis).execute
    @defaults = ANALYSIS_CHART_DEFAULTS.deep_merge(CODE_HISTORY_CHART_DEFAULTS)
  end

  def data_for_lines_of_code
    data.deep_merge(LINES_OF_CODE_CHART_DEFAULTS)
  end

  private

  def series_data_map
    [code_total_series, comment_total_series, blank_total_series]
  end

  def code_total_series
    series.map { |date| [date.ticks, date.code_total] }
  end

  def comment_total_series
    series.map { |date| [date.ticks, date.comments_total] }
  end

  def blank_total_series
    series.map { |date| [date.ticks, date.blanks_total] }
  end
end
