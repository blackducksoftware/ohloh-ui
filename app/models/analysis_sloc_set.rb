class AnalysisSlocSet < ActiveRecord::Base
  belongs_to :analysis
  belongs_to :sloc_set

  scope :for_repository, ->(repository_id) { joins(sloc_set: :repository).where(repositories: { id: repository_id }) }
end
