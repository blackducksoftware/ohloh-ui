# frozen_string_literal: true

class ActivityFactByMonthQuery
  SUM_COLUMNS = %i[code_added code_removed blanks_added blanks_removed
                   comments_added comments_removed commits].freeze

  def initialize(analysis)
    @analysis = analysis
  end

  def execute
    raise ActiveRecord::RecordNotFound if @analysis.nil?
    return [] if @analysis.min_month.blank?

    ActivityFact.find_by_sql(query)
  end

  private

  def query
    month = months[:month]
    months.project([month, summed_columns, distinct_column])
          .join(*joins_clause)
          .on(on_clause)
          .where(conditions)
          .group(month)
          .order(month)
  end

  def activities
    ActivityFact.arel_table
  end

  def months
    AllMonth.arel_table
  end

  def summed_columns
    SUM_COLUMNS.map { |column| activities[column].sum.as(column.to_s) }
  end

  def distinct_column
    activities[:name_id].count(true).as('contributors')
  end

  def joins_clause
    [activities, Arel::Nodes::OuterJoin]
  end

  def on_clause
    activities[:month].eq(months[:month])
  end

  def conditions
    equal_to.and(less_than).and(greater_than)
  end

  def equal_to
    activities[:analysis_id].eq(@analysis.id)
  end

  def less_than
    months[:month].lt(Time.current)
  end

  def greater_than
    months[:month].gteq(@analysis.min_month)
  end
end
