# frozen_string_literal: true

class Analysis::CodeFacts < Analysis::QueryBase
  arel_tables :all_month, :activity_fact

  def execute
    empty? ? [] : query
  end

  private

  def query
    AllMonth.select(select_columns).joins(joins_clause)
            .where(within_date).where(analysis_conditions)
            .where.not(activity_fact_conditions)
            .group(month).order(month)
  end

  def analysis_conditions
    activity_facts[:analysis_id].eq(@analysis.id)
  end

  def activity_fact_conditions
    activity_facts[:name_id].eq(nil)
  end

  def start_date
    truncate_date(@start_date)
  end

  def end_date
    last_month = [@analysis.activity_facts.maximum(:month), oldest_code_set_time].compact.max
    truncate_date(last_month.to_date)
  end

  def select_columns
    [month, super, activity_facts[:commits].sum.as('commits'), Arel.star.count.as('activity_months')]
  end
end
