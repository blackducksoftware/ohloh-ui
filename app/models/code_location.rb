class CodeLocation < ActiveRecord::Base
  belongs_to :repository
  belongs_to :best_code_set, foreign_key: :best_code_set_id, class_name: CodeSet
  has_many :enlistments
  has_many :jobs
  has_many :slave_logs, through: :jobs
  has_many :projects, through: :enlistments
  has_many :code_sets
  has_many :sloc_sets, through: :code_sets
  has_many :clumps, through: :code_sets

  include CodeLocationJobs

  accepts_nested_attributes_for :repository

  validate :scm_attributes_and_server_connection, unless: :bypass_url_validation

  attr_reader :bypass_url_validation

  def nice_url
    "#{repository.url} #{module_branch_name}"
  end

  def failed?
    jobs.order(:current_step_at).reverse.first.failed?
  end

  def create_enlistment_for_project(editor_account, project, ignore = nil)
    enlistment = Enlistment.where(project_id: project.id, code_location: id).first_or_initialize
    transaction do
      enlistment.editor_account = editor_account
      enlistment.assign_attributes(ignore: ignore)
      enlistment.save
      CreateEdit.find_by(target: enlistment).redo!(editor_account) if enlistment.deleted
    end
    enlistment.reload
  end

  class << self
    def find_existing(url, module_branch_name = nil)
      joins(:repository).where(repositories: { url: url })
        .where(module_branch_name: module_branch_name)
        .order(:id).first
    end

    def get_module_branch_name(module_branch_name)
    end
  end

  def bypass_url_validation=(value)
    modified_value = value == '0' ? false : value.present?
    @bypass_url_validation = modified_value
  end

  private

  def source_scm
    @source_scm ||= begin
      scm = repository.source_scm
      if repository.is_a?(CvsRepository)
        scm.module_name = module_branch_name
      else
        scm.branch_name = module_branch_name
      end
      scm.normalize
    end
  end

  def scm_attributes_and_server_connection
    normalize_scm_attributes
    source_scm.validate
    Timeout.timeout(timeout_interval) { source_scm.validate_server_connection }
  rescue Timeout::Error
    source_scm.errors << [:url, I18n.t('repositories.timeout')]
  ensure
    populate_scm_errors
  end

  def timeout_interval
    ENV['SCM_URL_VALIDATION_TIMEOUT'].to_i
  end

  def populate_scm_errors
    return if source_scm.errors.blank?

    source_scm.errors.each do |attr, error_message|
      errors.add(:module_branch_name, error_message) if [:branch_name, :module_name].include?(attr)
      repository.errors.add(attr, error_message)
    end
    errors.add(:base, nil)
  end

  def normalize_scm_attributes
    if repository.is_a?(CvsRepository)
      self.module_branch_name = source_scm.module_name
    else
      self.module_branch_name = source_scm.branch_name
    end
    normalize_repository_attributes
  end

  def normalize_repository_attributes
    repository.url = source_scm.url
    repository.username = source_scm.username
    repository.password = source_scm.password
  end
end
