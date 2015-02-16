class AnalysisDecorator < Cherry::Decorator
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
    year_summary              = object.twelve_month_summary
    previous_year_summary     = object.previous_twelve_month_summary

    return 0 if year_summary.nil? || previous_year_summary.nil?

    year_summary.send(column).to_i - previous_year_summary.send(column).to_i
  end
end
