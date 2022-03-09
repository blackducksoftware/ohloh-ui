# frozen_string_literal: true

class NameFact < ApplicationRecord
  include Comparable
  serialize :commits_by_project
  serialize :commits_by_language

  belongs_to :name, optional: true
  belongs_to :analysis, optional: true
  belongs_to :primary_language, class_name: 'Language', optional: true
  belongs_to :account_analysis, foreign_key: :vita_id, class_name: 'AccountAnalysis', optional: true
  has_one :project, -> { where("projects.deleted != 't'") }, foreign_key: :best_analysis_id, primary_key: :analysis_id

  scope :for_project, ->(project) { where(analysis_id: project.best_analysis_id) }
  scope :with_positions, lambda {
    joins(:project)
      .where('name_facts.name_id = positions.name_id and projects.id = positions.project_id')
      .arel.exists
  }

  def active?
    last_checkin.next_year > Time.current
  end

  def primary_language
    super || NilLanguage.new
  end

  def <=>(other)
    return 0 unless other

    if last_checkin.nil?
      return 0 if other.last_checkin.nil?

      return 1
    end
    return -1 if other.last_checkin.nil?

    other.last_checkin <=> last_checkin
  end
end
