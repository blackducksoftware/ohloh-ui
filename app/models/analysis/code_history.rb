class Analysis::CodeHistory < Analysis::Query
  arel_tables :activity_fact, :all_month

  def execute
    AllMonth.select([month, select_columns]).joins(joins_clause).where(within_date).group(month).order(month)
  end

  private

  def start_date
    truncate_date(@start_date)
  end

  def end_date
    truncate_date(@end_date)
  end

  def truncate_date(value)
    Arel::Nodes::NamedFunction.new('date_trunc', [Arel.sql("'month'"), Arel.sql("TIMESTAMP '#{value}'")])
  end
end
