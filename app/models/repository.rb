class Repository < ActiveRecord::Base
  include RepositoryJobs

  belongs_to :best_code_set, foreign_key: :best_code_set_id, class_name: CodeSet
  belongs_to :forge, class_name: 'Forge::Base'
  has_many :enlistments, -> { not_deleted }
  has_many :projects, through: :enlistments
  has_many :jobs
  has_many :code_sets
  has_many :slave_logs, through: :jobs
  has_many :sloc_sets, through: :code_sets
  has_many :clumps, through: :code_sets

  scope :matching, ->(match) { Repository.forge_match_search(match) }

  validates :url, presence: true, if: :bypass_url_validation
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
    job = jobs.order(:current_step_at).reverse.first
    job.failed?
  end

  def source_scm
    @source_scm ||= source_scm_class.new(attributes.symbolize_keys.merge(public_urls_only: !ENV['INTEGRATION_TEST']))
  end

  def source_scm_class
    OhlohScm::Adapters::AbstractAdapter
  end

  # Allows testing/development to skip validation.
  def bypass_url_validation=(value)
    modified_value = value == '0' ? false : value.present?
    @bypass_url_validation = modified_value
  end

  class << self
    def find_existing(repository)
      find_by(url: repository.url)
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
  end

  private

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
end
