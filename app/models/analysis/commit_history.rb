class Analysis::CommitHistory < Analysis::QueryBase
  attr_reader :start_date, :end_date

  arel_tables :analysis_alias, :commit, :analysis_sloc_set, :all_month

  def initialize(analysis:, name_id: nil, start_date: Analysis::EARLIEST_DATE, end_date: analysis.updated_on)
    @name_id = name_id
    super(analysis: analysis, start_date: start_date, end_date: end_date)
  end

  def execute
    Analysis.find_by_sql(query)
  end

  private

  def query
    all_months.project([month, coalesce_commits_count])
      .join(arel_subquery, Arel::Nodes::OuterJoin)
      .on(month.eq(arel_subquery[:this_month])).where(within_date)
      .order(month)
  end

  def arel_subquery
    subquery.arel.as('counts')
  end

  def subquery
    Commit.select(subquery_select_clause)
      .joins(analysis_aliases_joins)
      .where(code_set_id: subquery_conditions)
      .where(where_clause_conditions)
      .where(preferred_name_id)
      .group('this_month')
  end

  def where_clause_conditions
    analysis_aliases[:analysis_id].eq(@analysis.id)
      .and(commits[:time].gteq(start_date).and(commits[:time].lteq(end_date)))
  end

  def subquery_conditions
    AnalysisSlocSet.joins(sloc_set: :code_set).select('code_sets.id')
      .where(analysis_sloc_sets[:analysis_id].eq(@analysis.id))
  end

  def subquery_select_clause
    [Arel.star.count.as('count'), commit_date]
  end

  def analysis_aliases_joins
    commits
      .join(analysis_aliases)
      .on(commits[:name_id].eq(analysis_aliases[:commit_name_id]))
      .join_sources
  end

  def preferred_name_id
    @name_id ? analysis_aliases[:preferred_name_id].eq(@name_id) : nil
  end

  def coalesce_commits_count
    Arel::Nodes::NamedFunction.new('COALESCE', [arel_subquery[:count], 0]).as('commits')
  end

  def commit_date
    Arel::Nodes::NamedFunction.new('date_trunc', [Arel.sql("'month'"), commits[:time]]).as('this_month')
  end
end
