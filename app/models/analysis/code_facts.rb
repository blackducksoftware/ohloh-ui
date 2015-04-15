class Analysis::CodeFacts < Analysis::Query
  arel_tables :all_month, :activity_fact

  def collection
    execute.map { |fact| CodeFact.new(fact) }
  end

  def execute
    AllMonth.select(select_columns).joins(joins_clause)
            .where(within_date).where(activity_facts[:analysis_id].eq(@analysis.id))
            .where.not(activity_facts[:name_id].eq(nil))
            .group(month).order(month)
  end

  private

  def start_date
    truncate_date(@start_date)
  end

  def end_date
    last_month = [@analysis.activity_facts.maximum(:month), logged_at].compact.max
    truncate_date(last_month.to_date)
  end

  def select_columns
    [month, super, activity_facts[:commits].sum.as('commits'), Arel.star.count.as('activity_facts')]
  end
end
