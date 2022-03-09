# frozen_string_literal: true

class Analysis::LanguageHistoryChart < Analysis::Chart
  include ColorsHelper

  def initialize(analysis)
    super()
    @analysis = analysis
    @history = Analysis::LanguageHistory.new(analysis: analysis).execute
    @defaults = ANALYSIS_CHART_DEFAULTS.deep_merge(ANALYSIS_CHARTS_OPTIONS['language_history'])
  end

  def data
    chart = @defaults.merge('series' => series_map).deep_merge(chart_watermark)
    chart.merge range_selector
  end

  private

  def first_ticks
    series.map(&:ticks).min
  end

  def series_map
    top_5_languages.map do |lang|
      name = series.detect { |data| data.language == lang }.language_name
      { 'name' => lang, 'color' => "##{language_color(name)}", 'data' => series_lang_map(lang) }
    end
  end

  def series_lang_map(lang)
    series.select { |data| (data.language == lang) && (data.ticks > min_month_as_ticks) }
          .map { |data| [data.ticks, data.code_total] }
  end

  def top_5_languages
    series_langauge_code_total.to_a.sort { |a, b| b[1] <=> a[1] }.first(5).map(&:first)
  end

  def series_langauge_code_total
    series.each_with_object({}) { |data, hsh| hsh[data.language] = data.code_total }
  end

  def series
    months_to_ticks
  end
end
