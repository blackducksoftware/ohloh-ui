# frozen_string_literal: true

class AccountAnalysisFact < NameFact
  belongs_to :account_analysis, foreign_key: :vita_id, class_name: 'AccountAnalysis', optional: true

  def name_language_facts
    NameLanguageFact.joins(:language).where(vita_id: vita_id, analysis_id: analysis_id)
                    .order('languages.category', total_months: :desc,
                                                 total_commits: :desc,
                                                 total_activity_lines: :desc)
  end
end
