class AnalysisAlias < ActiveRecord::Base
  belongs_to :analysis
  belongs_to :commit_name, class_name: 'Name', foreign_key: :commit_name_id
  belongs_to :preferred_name, class_name: 'Name', foreign_key: :preferred_name_id

  scope :for_contribution, lambda { |contribution|
    name_fact = contribution.contributor_fact
    return AnalysisAlias.none if name_fact.nil?

    where(preferred_name_id: name_fact.name_id).where(analysis_id: name_fact.analysis_id)
  }
end
