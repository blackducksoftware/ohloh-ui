# frozen_string_literal: true

class Analysis::QueryBase
  SUM_COLUMNS = [%i[code_added code_removed code_total],
                 %i[comments_added comments_removed comments_total],
                 %i[blanks_added blanks_removed blanks_total]].freeze

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
    each_month_commits = @name_id ? contributor_monthly_commits : monthly_commits
    each_month_commits += missing_month_commits
    each_month_commits.select { |commit| commit.month.between?(start_date, end_date) }.sort_by(&:month)
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
    commit_histories = @name_id ? contributor_monthly_commits : monthly_commits
    AllMonth.where.not(month: commit_histories.map(&:month)).map do |all_month|
      MonthlyCommitHistory.new(month: all_month.month, commits: 0)
    end
  end

  def contributor_monthly_commits
    code_set_ids = AnalysisSlocSet.joins(:sloc_set).where(analysis_id: @analysis.id).pluck(:code_set_id)

    @contributor_monthly_commits ||= contributor_monthly_commits_query(code_set_ids).map do |c|
      MonthlyCommitHistory.new(month: DateTime.parse(c['month']).in_time_zone, commits: c['count'])
    end
  end

  def month
    all_months[:month]
  end

  def joins_clause
    all_months.join(activity_facts, Arel::Nodes::OuterJoin).on(on_clause).join_sources
  end

  def on_clause
    activity_facts[:month].eq(month).and(with_analysis)
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

  # rubocop:disable Metrics/MethodLength
  def contributor_monthly_commits_query(code_set_ids)
    return [] if code_set_ids.blank?

    commit_name_ids = AnalysisAlias.where(preferred_name_id: @name_id, analysis_id: @analysis.id).pluck(:commit_name_id)
    sql = <<-SQL.squish
      select to_char(date(C.time),'MON,YYYY') as month, count (*) as count
      FROM  commits C INNER JOIN code_sets CS ON C.code_set_id = CS.id
      INNER JOIN sloc_sets SS ON SS.code_set_id = CS.id INNER JOIN analysis_sloc_sets ASS ON ASS.sloc_set_id = SS.id
      WHERE ASS.analysis_id = #{@analysis.id} AND C.position <= ASS.as_of AND C.code_set_id in (#{code_set_ids.join(', ')}) AND C.name_id in (#{commit_name_ids.join(', ')})
      group by month
    SQL
    data = commit_name_ids.present? ? ApplicationRecord.connection.execute(sql).try(:to_json) : commit_name_ids.to_s
    JSON.parse(data)
  end
  # rubocop:enable Metrics/MethodLength
end
