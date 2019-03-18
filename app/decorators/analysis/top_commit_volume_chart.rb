class Analysis::TopCommitVolumeChart
  include ChartHelper
  include ActionView::Helpers::AssetUrlHelper

  OTHER = 'Other'.freeze
  NAME_COUNT = 5
  INTERVALS = ['50 years', '12 months', '1 month'].freeze

  def initialize(analysis)
    @analysis = analysis
    history_for_all_intervals
  end

  def data
    TOP_COMMIT_VOLUME_CHART_DEFAULTS.merge(data_options).deep_merge(chart_watermark(x_axis: '90%', y_axis: '14%'))
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
      'xAxis' => { 'categories' => interval_labels }, 'warning' => warning_message(@history[1]) }
  end

  def pivoted_series
    names = committer_names.map { |name| [name, []] }
    others = []
    @history.each do |interval|
      result = find_count(interval, names)
      others << result.last
    end
    names << [OTHER, others]
  end

  def committer_names
    all_names = []
    @history.each do |intervals|
      intervals.first(NAME_COUNT).each do |name, _count|
        all_names << name unless all_names.include? name
      end
    end
    all_names
  end

  def find_count(interval, names)
    total_count = interval.map(&:last).inject(:+).to_i
    committer_names.each_with_index do |name, i|
      _name, count = interval.find { |n, _count| n == name }
      names[i][1] << count.to_i
      total_count -= count.to_i
    end
    [names, total_count]
  end

  def warning_message(msg)
    half = msg.map { |_name, count| count }.sum / 2
    msg.each do |name, count|
      return I18n.t('top_commit_volume_chart.message', name: name) if count > half && name != OTHER
    end
    nil
  end
end
