class Enlistment < ActiveRecord::Base
  has_one :create_edit, as: :target
  has_many :project_badges
  has_many :travis_badges
  has_many :cii_badges
  belongs_to :code_location
  belongs_to :project

  has_one :repository, through: :code_location

  after_save :ensure_forge_and_job

  accepts_nested_attributes_for :code_location
  acts_as_editable editable_attributes: [:ignore]
  acts_as_protected parent: :project

  validates :ignore, length: { maximum: 1000 }, allow_nil: true

  scope :not_deleted, -> { where(deleted: false) }
  scope :by_url, -> { order('repositories.url, code_locations.module_branch_name') }
  scope :by_project, -> { order('projects.name, repositories.url, code_locations.module_branch_name') }
  scope :by_type, -> { order('repositories.type, repositories.url, code_locations.module_branch_name') }
  scope :by_module_name, -> { order('code_locations.module_branch_name, repositories.url') }
  scope :by_last_update, -> { joins(code_location: :code_sets).order('code_sets.updated_on DESC') }
  scope :with_repo_url, ->(url) { joins(code_location: :repository).where(Repository.arel_table[:url].eq(url)) }
  scope :failed_code_location_jobs, -> { joins(code_location: :jobs).where(jobs: { status: Job::STATUS_FAILED }) }

  filterable_by ['projects.name', 'repositories.url', 'code_locations.module_branch_name', 'repositories.type']

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
end
