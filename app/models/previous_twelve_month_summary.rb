# frozen_string_literal: true

class PreviousTwelveMonthSummary < AnalysisSummary
  def data?
    committer_count&.positive? && commits_count&.positive?
  end

  def commits_difference
    twelve_month_summ = analysis.twelve_month_summary
    return 0 unless twelve_month_summ

    twelve_month_summ.commits_count - commits_count
  end

  def committers_difference
    twelve_month_summ = analysis.twelve_month_summary
    return 0 unless twelve_month_summ

    twelve_month_summ.committer_count - committer_count
  end
end
