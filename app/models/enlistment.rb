class Enlistment < ActiveRecord::Base
  has_one :create_edit, as: :target
  belongs_to :repository
  belongs_to :project

  # TODO: Implement project forge
  # after_save :ensure_forge_and_job

  accepts_nested_attributes_for :repository
  acts_as_editable editable_attributes: [:ignore]
  acts_as_protected parent: :project

  validates :ignore, length: { maximum: 1000 }, allow_nil: true

  scope :not_deleted, -> { where(deleted: false) }
  scope :by_url, -> { order('repositories.url, repositories.module_name') }
  scope :by_project, -> { order('projects.name, repositories.url, repositories.module_name') }
  scope :by_type, -> { order('repositories.type, repositories.url, repositories.module_name') }
  scope :by_module_name, -> { order('repositories.module_name, repositories.url') }
  scope :with_repo_url, ->(url) { joins(:repository).where(Repository.arel_table[:url].eq(url)) }

  filterable_by ['projects.name', 'repositories.url', 'repositories.module_name',
                 'repositories.type', 'repositories.branch_name']

  def analysis_sloc_set
    return if project.best_analysis.nil?
    AnalysisSlocSet.for_repository(repository_id).where(analysis_id: project.best_analysis_id).first
  end

  def ignore_examples
    repository.best_code_set.fyles.limit(3).pluck(:name).sort if repository.best_code_set
  end

  class << self
    def enlist_project_in_repository(editor_account, project, repository, ignore = nil)
      enlistment = Enlistment.where(project_id: project.id, repository_id: repository.id).first_or_initialize
      transaction do
        enlistment.editor_account = editor_account
        enlistment.assign_attributes(ignore: ignore)
        enlistment.save
        CreateEdit.where(target: enlistment).first.redo!(editor_account) if enlistment.deleted
      end
      enlistment.reload
    end
  end
end
