class TopCommitVolumeChart < CommitVolumeChart
  NAME_COUNT = 8

  def initialize(analysis)
    super
    @interval_labels = ['All<br/>Time', '12-Month<br/>Summary', '30-Day<br/>Summary']
  end

  def data
    TOP_COMMIT_VOLUME_CHART_DEFAULTS.merge(data_options)
  end
end
