class AnalysisCommitHistoryQuery
  def initialize(analysis, name_id, start_date, end_date)
    @analysis_id = analysis.id
    @name_id = name_id
    start_date ||= Analysis::EARLIEST_DATE
    end_date ||= analysis.updated_on

    @start_month = start_date.strftime('%Y-%m-01')
    @end_month = end_date.strftime('%Y-%m-01')
  end

  def execute
    Analysis.find_by_sql(query)
  end

  private

  def query
    months.project([month, coalesce_commits_count])
      .join(subquery, Arel::Nodes::OuterJoin)
      .on(month.eq(subquery[:this_month]))
      .where(query_conditions)
      .order(month)
  end

  def subquery
    AnalysisSlocSet.select([Arel.star.count.as('count'), truncate_date])
      .joins(sloc_set: { code_set: :commits })
      .joins(analysis_aliases_joins)
      .where(subquery_conditions)
      .group('this_month')
      .order('this_month')
      .arel.as('counts')
  end

  def query_conditions
    month.gteq(@start_month).and(month.lteq(@end_month))
  end

  def subquery_conditions
    commits[:position].lteq(analysis_sloc_sets[:as_of])
      .and(analysis_aliases[:analysis_id].eq(@analysis_id))
      .and(analysis_sloc_sets[:analysis_id].eq(@analysis_id))
      .and(preferred_name_id)
  end

  def analysis_aliases_joins
    analysis_sloc_sets
      .join(analysis_aliases)
      .on(commits[:name_id].eq(analysis_aliases[:commit_name_id]))
      .join_sources
  end

  def preferred_name_id
    @name_id ? analysis_aliases[:preferred_name_id].eq(@name_id) : nil
  end

  def coalesce_commits_count
    Arel::Nodes::NamedFunction.new('COALESCE', [subquery[:count], 0]).as('commits')
  end

  def truncate_date
    Arel::Nodes::NamedFunction.new('date_trunc', [Arel.sql("'month'"), commits[:time]]).as('this_month')
  end

  def analysis_sloc_sets
    AnalysisSlocSet.arel_table
  end

  def months
    AllMonth.arel_table
  end

  def analysis_aliases
    AnalysisAlias.arel_table
  end

  def commits
    Commit.arel_table
  end

  def month
    months[:month]
  end
end
