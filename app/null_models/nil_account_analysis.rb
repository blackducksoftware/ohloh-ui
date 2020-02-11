# frozen_string_literal: true

class NilAccountAnalysis < NullObject
  def account_analysis_fact
    NilAccountAnalysisFact.new
  end

  def account_analysis_language_facts
    AccountAnalysisLanguageFact.none
  end

  def id
    0
  end
end
