# frozen_string_literal: true

class Analysis::ContributorHistory < Analysis::QueryBase
  attr_reader :start_date, :end_date

  arel_tables :all_month, :activity_fact

  def execute
    AllMonth.select(select_columns).joins(joins_clause).where(within_date).group(month).order(month)
  end

  private

  def select_columns
    [month, activity_facts[:name_id].count(true).as('contributors')]
  end

  def on_clause
    activity_facts[:month].eq(month).and(activity_facts[:analysis_id].eq(@analysis.id))
  end
end
