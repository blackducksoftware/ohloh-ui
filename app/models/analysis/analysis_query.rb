class Analysis::Query
  SUM_COLUMNS = [[:code_added, :code_removed, :code_total],
                 [:comments_added, :comments_removed, :comments_total],
                 [:blanks_added, :blanks_removed, :blanks_total]]

  delegate :logged_at, :updated_on, :empty?, to: :@analysis

  class << self
    def arel_tables(*args)
      args.each do |table_name|
        define_method table_name.to_s.pluralize do
          table_name.to_s.camelize.constantize.arel_table
        end
      end
    end
  end

  def initialize(analysis:, start_date: Analysis::EARLIEST_DATE, end_date: analysis.updated_on)
    @analysis = analysis
    @start_date = Date.parse start_date.strftime('%Y-%m-01')
    @end_date = Date.parse end_date.strftime('%Y-%m-01')
  end

  private

  def month
    all_months[:month]
  end

  def joins_clause
    all_months.join(activity_facts, Arel::Nodes::OuterJoin).on(on_clause).join_sources
  end

  def on_clause
    activity_facts[:month].lteq(month).and(with_analysis)
  end

  def select_columns
    SUM_COLUMNS.map { |column_names| differential_sum(column_names) }
  end

  def truncate_date(value)
    Arel::Nodes::NamedFunction.new('date_trunc', [Arel.sql("'month'"), value])
  end

  def differential_sum(column_names)
    node = Arel::Nodes::InfixOperation.new(:-, activity_facts[column_names.first], activity_facts[column_names.second])
    node.sum.as(column_names.last.to_s)
  end

  def within_date
    month.gteq(start_date).and(month.lteq(end_date))
  end

  def with_analysis
    activity_facts[:on_trunk].eq(true).and(activity_facts[:analysis_id].eq(@analysis.id))
  end
end
