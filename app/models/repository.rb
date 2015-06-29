class Repository < ActiveRecord::Base
  belongs_to :best_code_set, foreign_key: :best_code_set_id, class_name: CodeSet
  has_many :enlistments, -> { not_deleted }
  has_many :projects, through: :enlistments
  has_many :jobs

  scope :matching, ->(match) { Repository.forge_match_search(match) }

  validates :url, presence: true
  validate :scm_attributes_and_server_connection

  attr_accessor :forge_match, :bypass_url_validation

  def nice_url
    "#{url} #{branch_name}"
  end

  def english_name
    # TODO: scm source adapter
  end

  def failed?
    job = jobs.incomplete.first
    return true if job && job.status == Job::STATUS_FAILED
    false
  end

  def source_scm
    @source_scm ||= source_scm_class.new(attributes.symbolize_keys.merge(public_urls_only: !ENV['INTEGRATION_TEST']))
  end

  def source_scm_class
    OhlohScm::Adapters::AbstractAdapter
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
  end

  private

  def scm_attributes_and_server_connection
    return unless should_validate?
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

  # Allows testing/development to skip validation.
  def should_validate?
    bypass_url_validation && bypass_url_validation != '0'
  end
end
