class Analysis::MonthlyCommits < Analysis::Query
  COMMIT_YEARS = 5

  arel_tables :commit, :analysis_sloc_set, :all_month

  def execute
    AllMonth.select([month, sub_query.arel.as('commits')]).where(within_date).order(month)
  end

  private

  def sub_query
    AnalysisSlocSet.select([Arel.star.count])
      .joins(sloc_set: { code_set: :commits })
      .where(commits[:position].lteq(analysis_sloc_sets[:as_of]))
      .where(analysis_sloc_sets[:analysis_id].eq(@analysis.id))
      .where(month.eq(truncate_date(commits[:time])))
  end

  def start_date
    Time.now.utc - COMMIT_YEARS.years
  end

  def end_date
    Time.now.utc
  end
end
