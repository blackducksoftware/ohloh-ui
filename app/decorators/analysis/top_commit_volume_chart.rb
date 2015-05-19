class Analysis::TopCommitVolumeChart
  include ChartHelper
  include ActionView::Helpers::AssetUrlHelper

  OTHER = 'Other'
  NAME_COUNT = 8
  INTERVALS = ['50 years', '12 months', '1 month']

  def initialize(analysis)
    @analysis = analysis
    history_for_all_intervals
  end

  def data
    TOP_COMMIT_VOLUME_CHART_DEFAULTS.merge(data_options).deep_merge(chart_watermark(x: '90%', y: '14%'))
  end

  private

  def interval_labels
    ['All<br/>Time', '12-Month<br/>Summary', '30-Day<br/>Summary']
  end

  def history_for_all_intervals
    @history = INTERVALS.map do |interval|
      Analysis::TopCommitVolume.new(@analysis, interval).collection
    end
  end

  def data_options
    { 'series' => pivoted_series.map { |name, data| { 'name' => name, 'data' => data } },
      'xAxis' => { 'categories' => interval_labels }, 'warning' => nil }
  end

  def series
    @series ||= @history.map do |data|
      others_count = data.drop(NAME_COUNT).map(&:last).sum
      data.take(NAME_COUNT) + [[OTHER, others_count]]
    end
  end

  def pivoted_series
    @pivoted_series ||= committer_names.map { |name| [name, find_count(name)] }
  end

  def find_count(name_to_find)
    series.map do |data|
      data.find { |name, _| name == name_to_find }.try(:last).to_i
    end
  end

  def committer_names
    @comitter_names ||= series.map { |data| data.map(&:first) }.flatten.uniq
  end
end
