class Analysis::CommitVolumeChart
  OTHER = 'Other'
  NAME_COUNT = 5
  INTERVALS = ['50 years', '12 months', '1 month']

  def initialize(analysis)
    @analysis = analysis
    history_for_all_intervals
    @interval_labels = ['All Time', 'Past 12 Months', @analysis.max_month.strftime('%B %Y')]
  end

  def data
    COMMIT_VOLUME_CHART_DEFAULTS.merge(data_options)
  end

  private

  def data_options
    { 'series' => pivoted_series.map { |name, data| { 'name' => name, 'data' => data } },
      'xAxis' => { 'categories' => @interval_labels }, 'warning' => warning_messages }
  end

  def history_for_all_intervals
    @history = INTERVALS.map do |interval|
      Analysis::CommitVolume.new(@analysis, interval).collection
    end
  end

  def series
    @series ||= @history.map do |data|
      others_count = data.drop(NAME_COUNT).map(&:last).sum
      data.take(NAME_COUNT) + [OTHER, others_count]
    end
  end

  def pivoted_series
    @pivoted_series ||= committer_names.map { |name| [name, find_count(name)] }
  end

  def find_count(name_to_find)
    series.map do |data|
      data.find { |name, _| name == name_to_find }.last
    end
  end

  def committer_names
    @comitter_names ||= series.map { |data| data.map(&:first) }.flatten.uniq
  end

  def warning_messages
    committers_with_most_commits_last_year.map do |name, count|
      "#{name} generated more than 50% of all commits during the past 12 months."
    end
  end

  def committers_with_most_commits_last_year
    half_of_commits_count = series[1].map(&:last).sum / 2
    series[1].take(NAME_COUNT).reject { |datum| datum.last < half_of_commits_count }
  end
end
