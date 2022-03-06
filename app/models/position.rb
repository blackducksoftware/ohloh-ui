# frozen_string_literal: true

class Position < ApplicationRecord
  include AffiliationValidation
  include Position::Validations

  attr_reader :project_oss

  belongs_to :account, optional: true
  belongs_to :project, optional: true
  belongs_to :organization, optional: true
  belongs_to :name, optional: true
  # we have a method named organization to maintain backward compatibility
  belongs_to :affiliation, class_name: 'Organization', foreign_key: :organization_id, optional: true
  has_one :contribution
  has_many :language_experiences, dependent: :destroy
  has_many :project_experiences, dependent: :destroy
  has_many :name_facts, foreign_key: :name_id, primary_key: :name_id

  scope :claimed_by, ->(account) { where(account_id: account.id).where.not(name_id: nil) }
  scope :for_project, ->(project) { where(project_id: project.id) }
  scope :active, lambda {
    where('EXISTS (SELECT * FROM name_facts INNER JOIN projects ON projects.best_analysis_id = name_facts.analysis_id
    AND name_facts.name_id = positions.name_id AND projects.id = positions.project_id)')
  }

  after_create Position::Hooks.new
  after_update Position::Hooks.new
  after_destroy Position::Hooks.new
  after_save Position::Hooks.new

  accepts_nested_attributes_for :project_experiences, allow_destroy: true, reject_if: :all_blank

  def contribution_id
    return nil unless name_id

    Contribution.generate_id_from_project_id_and_name_id(project_id, name_id)
  end

  def name_fact
    return nil unless project.best_analysis_id && name_id

    @name_fact ||= NameFact.find_by('analysis_id = ? AND name_id = ?', project.best_analysis_id, name_id)
  end

  def committer_name
    @committer_name || name&.name
  end

  def committer_name=(name)
    @committer_name = name.presence

    return unless committer_name_and_project?

    name_fact = find_name_fact_from_project_and_comitter_name
    self.name_id = name_fact.try(:name_id)
  end

  def project_oss=(oss)
    @project_oss = oss
    self.project = Project.not_deleted.find_by('lower(name) = ?', oss.to_s.downcase)
  end

  def one_monther?
    return false if ongoing?

    start = effective_start_date
    stop = effective_stop_date
    start.month == stop.month && start.year == stop.year
  end

  def effective_start_date
    start_date || name_fact.try(:first_checkin)
  end

  # 2 possible values
  # time: this is when it stopped
  # nil: unknown (for some reason)
  def effective_stop_date
    stop_date || (ongoing && Time.current) ||
      (name_fact.try(:active?) && Time.current) ||
      name_fact.try(:last_checkin) || Time.current
  end

  def effective_duration
    effective_stop_date - effective_start_date
  end

  # a position can be ongoing for 2 reasons:
  # 1. It was indicated as such (checked 'ongoing!')
  # 2. It was marked as 'auto' and the person made a commit in the last 12 months (yeah, we consider that ongoing)
  def effective_ongoing?
    ongoing || (stop_date.nil? && name_fact.try(:active?))
  end

  def active?
    effective_ongoing? && !(stop_date.present? && stop_date < Time.current)
  end

  def organization
    organization_name.presence || affiliation.try(:name)
  end

  def language_exp=(language_ids)
    Array(language_ids).each do |language_id|
      language_experiences << LanguageExperience.new(language_id: language_id.to_i)
    end
  end

  private

  def find_name_fact_from_project_and_comitter_name
    NameFact.joins(:name).find_by('analysis_id = ? AND names.name = ?', project.best_analysis_id, committer_name)
  end

  def committer_name_and_project?
    committer_name && project
  end
end
