# frozen_string_literal: true

class NilAccountAnalysis < NullObject
  nought_methods :id

  def account_analysis_fact
    NilAccountAnalysisFact.new
  end

  def account_analysis_language_facts
    AccountAnalysisLanguageFact.none
  end
end
