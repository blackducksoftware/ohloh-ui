class NilAnalysis < NullObject
  def twelve_month_summary
    NilAnalysisSummary.new
  end

  def previous_twelve_month_summary
    NilAnalysisSummary.new
  end

  def main_language
    nil
  end

  def activity_level
    :na
  end

  def name_fact_for(_name_id)
    false
  end
end
