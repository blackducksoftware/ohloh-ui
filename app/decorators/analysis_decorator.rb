# frozen_string_literal: true

class AnalysisDecorator < Cherry::Decorator
  delegate :twelve_month_summary, :previous_twelve_month_summary, :commit_count, :markup_total, :logic_total,
           to: :object

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

  def display_chart?
    return [false, :no_commits] if commit_count.nil? || commit_count <= 0
    return [false, :no_understood_lang] if logic_total <= 0 && markup_total <= 0

    [true, nil]
  end

  private

  def year_ago_summary_difference(column)
    return unless twelve_month_summary.respond_to?(column)

    twelve_month_summary.send(column).to_i - previous_twelve_month_summary.send(column).to_i
  end
end
