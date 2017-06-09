class Analysis::QueryBase
  SUM_COLUMNS = [[:code_added, :code_removed, :code_total],
                 [:comments_added, :comments_removed, :comments_total],
                 [:blanks_added, :blanks_removed, :blanks_total]].freeze

  delegate :oldest_code_set_time, :updated_on, :empty?, to: :@analysis

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
    @start_date = start_date.beginning_of_month
    @end_date = end_date.beginning_of_month
  end

  def monthly_commit_histories
    each_month_commits = monthly_commits + missing_month_commits
    each_month_commits.select { |commit| commit.month >= start_date && commit.month <= end_date }.sort_by(&:month)
  end

  private

  def monthly_commits
    @monthly_commits ||= parsed_monthly_commits.map do |commit_date, commit_count|
      MonthlyCommitHistory.new(month: Time.zone.parse(commit_date), commits: commit_count)
    end
  end

  def parsed_monthly_commits
    JSON.parse(MonthlyCommitHistory.find_by(analysis_id: @analysis.id).try(:json) || {}.to_json)
  end

  def missing_month_commits
    AllMonth.where.not(month: monthly_commits.map(&:month)).map do |all_month|
      MonthlyCommitHistory.new(month: all_month.month, commits: 0)
    end
  end

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
    Arel::Nodes::NamedFunction.new('date_trunc', [Arel.sql("'month'"), Arel.sql("TIMESTAMP '#{value}'")])
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
