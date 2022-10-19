# frozen_string_literal: true

class NilAnalysis < NullObject
  attr_reader :main_language, :oldest_code_set_time

  nil_methods :last_commit_time, :commit_count, :scan_analytics
  empty_methods :contributor_facts
  nought_methods :logic_total, :markup_total, :build_total, :code_total, :headcount

  def twelve_month_summary
    NilAnalysisSummary.new
  end

  def previous_twelve_month_summary
    NilAnalysisSummary.new
  end

  def name_fact_for(_name_id)
    false
  end

  def activity_level
    :na
  end

  def man_years_from_loc(_loc)
    0
  end

  def factoids
    Factoid.none
  end

  def empty?
    true
  end

  def updated_on
    Time.zone.now
  end
end
