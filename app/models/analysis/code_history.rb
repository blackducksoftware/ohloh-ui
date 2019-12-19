# frozen_string_literal: true

class Analysis::CodeHistory < Analysis::QueryBase
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
end
