class Analysis::LanguageHistoryChart < Analysis::Chart
  def initialize(analysis)
    @analysis = analysis
    @history = Analysis::LanguageHistory.new(analysis)
    @defaults = ANALYSIS_CHART_DEFAULTS.deep_merge(LANGUAGE_HISTORY_CHART)
  end

  def data
    chart = @defaults.merge('series' => series_map)
    chart.merge! range_selector(history.map { |x| x['ticks'] }.min)
  end

  private

  def series_map
    top_5_languages.map do |lang|
      name = series.detect { |x| x["language"] == lang }['language_name']
      { 'name' => lang, 'color' => "##{language_color(name)}", 'data' => series_data_map(lang) }
    end
  end

  def series_data_map(lang)
    series.select { |data| (data['language'] == lang) && (x['ticks'] > min_month_as_ticks) }
          .map { |data| [x['ticks'], x['code_total'].to_i] }
  end

  def top_5_languages
    series_langauge_code_total.to_a.sort { |a, b| b[1] <=> a[1] }.first(5).map(&:first)
  end

  def series_langauge_code_total
    series.each_with_object({}) do |hsh, data|
      hsh[data['language']] = data['code_total'].to_i
    end
  end

  def series
    months_to_ticks(@history)
  end
end
