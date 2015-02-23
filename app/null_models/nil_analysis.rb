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

  def name_fact_for(_name_id)
    false
  end

  def project
    nil
  end

  def activity_level
    nil
  end

  def activity_score
    0
  end

  def updated_on
    nil
  end

  def first_commit_time
    nil
  end

  def last_commit_time
    nil
  end

  def headcount
    nil
  end
end
