# frozen_string_literal: true

class Analysis::CommitHistory < Analysis::QueryBase
  attr_reader :start_date, :end_date

  arel_tables :analysis_alias, :commit, :analysis_sloc_set, :all_month

  def initialize(analysis:, name_id: nil, start_date: Analysis::EARLIEST_DATE, end_date: analysis.updated_on)
    @name_id = name_id
    super(analysis: analysis, start_date: start_date, end_date: end_date)
  end

  def execute
    monthly_commit_histories
  end
end
