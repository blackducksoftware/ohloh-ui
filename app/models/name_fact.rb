class NameFact < ActiveRecord::Base
  include Comparable
  serialize :commits_by_project
  serialize :commits_by_language

  belongs_to :name
  belongs_to :analysis
  belongs_to :primary_language, class_name: 'Language', foreign_key: :primary_language_id
  has_one :project, -> { where { deleted.not_eq(true) } }, foreign_key: :best_analysis_id, primary_key: :analysis_id

  scope :for_project, ->(project) { where(analysis_id: project.best_analysis_id) }

  def <=>(other)
    return -1 if other.nil?
    other.last_checkin <=> last_checkin
  end
end
