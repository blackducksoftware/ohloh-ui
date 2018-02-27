class Enlistment < ActiveRecord::Base
  has_one :create_edit, as: :target
  has_many :project_badges
  has_many :travis_badges
  has_many :cii_badges
  belongs_to :project

  before_save :save_code_location, if: -> { @nested_code_location }
  after_save :ensure_forge_and_job
  after_update :update_subscription, if: :deleted_changed?

  acts_as_editable editable_attributes: [:ignore]
  acts_as_protected parent: :project

  validates :ignore, length: { maximum: 1000 }, allow_nil: true
  validate :validate_code_location, if: -> { @nested_code_location }

  scope :not_deleted, -> { where(deleted: false) }
  scope :by_url, -> { order('repositories.url, code_locations.module_branch_name') }
  scope :by_project, -> { order('projects.name, repositories.url, code_locations.module_branch_name') }
  scope :by_type, -> { order('repositories.type, repositories.url, code_locations.module_branch_name') }
  scope :by_module_name, -> { order('code_locations.module_branch_name, repositories.url') }
  # TODO: Check history to see where this was being used before.
  # scope :with_repo_url, ->(url) { joins(code_location: :repository).where(Repository.arel_table[:url].eq(url)) }
  scope :by_last_update, lambda {
    joins('left join code_sets on code_sets.id = code_locations.best_code_set_id')
      .order('code_sets.updated_on DESC')
  }
  scope :by_update_status, lambda {
    joins('left join jobs on jobs.code_location_id = enlistments.code_location_id')
      .group('enlistments.id').order('min(jobs.status), max(jobs.current_step_at) DESC')
  }

  filterable_by ['projects.name', 'repositories.url', 'code_locations.module_branch_name', 'repositories.type']

  attr_writer :code_location

  def code_location
    @code_location ||= CodeLocation.find(code_location_id)
  end

  def code_location_attributes=(hsh)
    @nested_code_location = true
    @code_location = CodeLocation.new(hsh)
  end

  def analysis_sloc_set
    return if project.best_analysis.nil?
    AnalysisSlocSet.for_code_location(code_location_id).find_by(analysis_id: project.best_analysis_id)
  end

  def ignore_examples
    code_location.best_code_set.fyles.limit(3).map(&:name).sort if code_location.best_code_set
  end

  def ensure_forge_and_job
    project.reload
    unless project.forge_match
      forge_match = (project.forge_match = project.guess_forge)
      project.save if forge_match
    end
    project.ensure_job
  end

  def save_code_location
    if @code_location.save
      self.code_location_id = @code_location.id
    else
      errors.add(:base, 'CodeLocation not saved')
    end
  end

  def validate_code_location
    errors.add(:base, 'Invalid url or branch name') unless @code_location.valid?
  end

  def update_subscription
    params = { code_location_id: code_location_id, client_relation_id: project_id }
    return CodeLocationSubscription.new(params).delete if deleted
    CodeLocationSubscription.create(params)
  end
end
