class Analysis::TopCommitVolumeChart < Analysis::CommitVolumeChart
  INTERVALS = ['50 years', '12 months', '1 month']
  NAME_COUNT = 8

  def data
    TOP_COMMIT_VOLUME_CHART_DEFAULTS.merge(data_options)
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
end
