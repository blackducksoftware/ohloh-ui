class Repository < ActiveRecord::Base
  belongs_to :best_code_set, foreign_key: :best_code_set_id, class_name: CodeSet
  belongs_to :forge, class_name: 'Forge::Base'
  has_many :enlistments, -> { not_deleted }
  has_many :projects, through: :enlistments
  has_many :jobs

  scope :matching, ->(match) { Repository.forge_match_search(match) }

  validates :url, presence: true
  validate :scm_attributes_and_server_connection, unless: :bypass_url_validation

  attr_accessor :forge_match
  attr_reader :bypass_url_validation

  def nice_url
    "#{url} #{branch_name}"
  end

  def name_in_english
    source_scm.english_name
  end

  def failed?
    jobs.incomplete.first.try(:failed?)
  end

  def source_scm
    @source_scm ||= source_scm_class.new(attributes.symbolize_keys.merge(public_urls_only: !ENV['INTEGRATION_TEST']))
  end

  def source_scm_class
    OhlohScm::Adapters::AbstractAdapter
  end

  def ensure_job(priority = 0)
    job = jobs.incomplete.first
    return job if job
    job = create_fetch_job(priority) if best_code_set.blank?
    job = create_import_or_sloc_jobs(priority) if best_code_set.present?
    job
  end

  # Allows testing/development to skip validation.
  def bypass_url_validation=(value)
    modified_value = value == '0' ? false : value.present?
    @bypass_url_validation = modified_value
  end

  def clump_class
    GitClump
  end

  def create_next_job(priority = 0)
    if best_code_set
      CompleteJob.try_create(best_code_set, priority)
    else
      ensure_job(priority)
    end
  end

  class << self
    def find_existing(repository)
      where(url: repository.url).first
    end

    def get_compatible_class(_url)
      self
    end

    def forge_match_search(m)
      wheres = where(forge_id: m.forge.id).where(['lower(repositories.name_at_forge) = ?', m.name_at_forge.downcase])
      if m.owner_at_forge
        wheres.where(['lower(repositories.owner_at_forge) = ?', m.owner_at_forge.downcase])
      else
        wheres.where(owner_at_forge: nil)
      end
    end

    def dag?
      false
    end

    def email_addresses?
      true
    end
  end

  private

  def scm_attributes_and_server_connection
    normalize_scm_attributes
    source_scm.validate
    source_scm.validate_server_connection

    source_scm.errors.each do |attribute, error_message|
      errors.add(attribute, error_message)
    end
  end

  def normalize_scm_attributes
    source_scm.normalize

    self.url         = source_scm.url
    self.branch_name = source_scm.branch_name
    self.username    = source_scm.username
    self.password    = source_scm.password
  end

  def create_fetch_job(priority)
    cs = CodeSet.where(repository: self).first_or_create
    FetchJob.create(code_set: cs, priority: priority)
  end

  def create_import_or_sloc_jobs(priority)
    sloc_set = best_code_set.best_sloc_set
    if sloc_set.blank?
      ImportJob.create(code_set: best_code_set, priority: priority)
    elsif sloc_set.as_of.to_i < best_code_set.as_of.to_i
      SlocJob.create(sloc_set: sloc_set, priority: priority)
    end
  end
end
