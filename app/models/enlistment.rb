class Enlistment < ActiveRecord::Base
  has_one :create_edit, as: :target
  has_one :code_location, through: :repository, source: :prime_code_location
  belongs_to :repository
  belongs_to :project

  after_save :ensure_forge_and_job

  accepts_nested_attributes_for :repository
  acts_as_editable editable_attributes: [:ignore]
  acts_as_protected parent: :project

  validates :ignore, length: { maximum: 1000 }, allow_nil: true

  scope :not_deleted, -> { where(deleted: false) }
  scope :by_url, -> { joins(:code_location).order('repositories.url, code_locations.branch_name') }
  scope :by_project, -> { joins(:code_location).order('projects.name, repositories.url, code_locations.branch_name') }
  scope :by_type, -> { joins(:code_location).order('repositories.type, repositories.url, code_locations.branch_name') }
  scope :by_module_name, -> { joins(:code_location).order('code_locations.branch_name, repositories.url') }
  scope :with_repo_url, ->(url) { joins(:repository).where(Repository.arel_table[:url].eq(url)) }
  scope :with_failed_repository_jobs, -> { joins(repository: :jobs).where(jobs: { status: Job::STATUS_FAILED }) }

  filterable_by ['projects.name', 'repositories.url', 'repositories.type', 'code_locations.branch_name']

  def analysis_sloc_set
    return if project.best_analysis.nil?
    AnalysisSlocSet.for_repository(repository_id).find_by(analysis_id: project.best_analysis_id)
  end

  def ignore_examples
    repository.best_code_set.fyles.limit(3).map(&:name).sort if repository.best_code_set
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
