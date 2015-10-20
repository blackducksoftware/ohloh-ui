class Analysis::MonthlyCommitHistory
  def initialize(analysis:, name_id: nil, start_date: Analysis::EARLIEST_DATE, end_date: analysis.updated_on)
    @analysis = analysis
    @name_id = name_id
    @start_date = start_date
    @end_date = end_date
  end

  def execute
    commits = ActiveRecord::Base.connection.execute(commit_history.subquery.to_sql).to_a

    (all_months + commits)
      .group_by { |hsh| hsh['this_month'] }
      .map { |_k, v| v.reduce(:merge) }
      .map(&:symbolize_keys)
  end

  private

  def all_months
    AllMonth.all_attributes(start_date, end_date)
  end

  def commit_history
    Analysis::CommitHistory.new(analysis: @analysis, name_id: @name_id, start_date: @start_date, end_date: @end_date)
  end

  def start_date
    @start_date.beginning_of_month.to_s(:db)
  end

  def end_date
    @end_date.beginning_of_month.to_s(:db)
  end
end
