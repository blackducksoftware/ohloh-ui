# frozen_string_literal: true

class Analysis::MonthlyCommits < Analysis::QueryBase
  COMMIT_YEARS = 5

  arel_tables :commit, :analysis_sloc_set, :all_month

  def execute
    monthly_commit_histories
  end

  private

  def start_date
    Time.current - COMMIT_YEARS.years
  end

  def end_date
    Time.current
  end
end
