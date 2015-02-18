class AnalysisDecorator < Cherry::Decorator
  delegate :twelve_month_summary, :previous_twelve_month_summary, to: :object

  def commits_difference
    year_ago_summary_difference('commits_count')
  end

  def committers_difference
    year_ago_summary_difference('committer_count')
  end

  def affiliated_commits_difference
    year_ago_summary_difference('affiliated_commits_count')
  end

  def affiliated_committers_difference
    year_ago_summary_difference('affiliated_committers_count')
  end

  def outside_commits_difference
    year_ago_summary_difference('outside_commits_count')
  end

  def outside_committers_difference
    year_ago_summary_difference('outside_committers_count')
  end

  private

  def year_ago_summary_difference(column)
    twelve_month_summary.send(column).to_i - previous_twelve_month_summary.send(column).to_i
  end
end
