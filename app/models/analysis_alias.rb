# frozen_string_literal: true

class AnalysisAlias < FisBase
  belongs_to :analysis, optional: true
  belongs_to :commit_name, class_name: 'Name', optional: true
  belongs_to :preferred_name, class_name: 'Name', optional: true
  has_one :project, through: :analysis

  scope :for_contribution, lambda { |contribution|
    name_fact = contribution.contributor_fact
    return AnalysisAlias.none if name_fact.nil?

    where(preferred_name_id: name_fact.name_id).where(analysis_id: name_fact.analysis_id)
  }

  scope :commit_name_ids, lambda { |contributor_fact|
    where(preferred_name_id: contributor_fact.name_id, analysis_id: contributor_fact.analysis_id)
      .pluck(:commit_name_id)
  }
end
