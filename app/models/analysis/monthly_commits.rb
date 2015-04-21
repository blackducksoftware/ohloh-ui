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
      .where(subquery_conditions)
      .where(month.eq(truncate_date(commits[:time])))
  end

  def subquery_conditions
    commits[:position].lteq(analysis_sloc_sets[:as_of]).and analysis_sloc_sets[:analysis_id].eq(@analysis.id)
  end

  def truncate_date(value)
    Arel::Nodes::NamedFunction.new('date_trunc', [Arel.sql("'month'"), value])
  end

  def start_date
    Time.now.utc - COMMIT_YEARS.years
  end

  def end_date
    Time.now.utc
  end
end
