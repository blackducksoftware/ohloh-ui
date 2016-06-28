class Repository < ActiveRecord::Base
  include RepositoryJobs
  include ScmValidation

  belongs_to :best_code_set, foreign_key: :best_code_set_id, class_name: CodeSet
  belongs_to :forge, class_name: 'Forge::Base'
  belongs_to :prime_code_location, class_name: CodeLocation
  has_many :code_locations
  has_many :enlistments, -> { not_deleted }
  has_many :projects, through: :enlistments
  has_many :jobs
  has_many :code_sets
  has_many :slave_logs, through: :jobs
  has_many :sloc_sets, through: :code_sets
  has_many :clumps, through: :code_sets

  scope :matching, ->(match) { Repository.forge_match_search(match) }

  validates :url, presence: true, if: :bypass_url_validation

  after_create :set_repository_id_for_prime_code_location, if: :prime_code_location

  attr_accessor :forge_match, :branch_name # forge.get_repository_attributes
  attr_reader :bypass_url_validation

  accepts_nested_attributes_for :prime_code_location

  def nice_url
    "#{url} #{prime_code_location.try(:branch_name)}"
  end

  def name_in_english
    source_scm.english_name
  end

  def failed?
    job = jobs.order(:current_step_at).reverse.first
    job.failed?
  end

  def source_scm
    traits = attributes.symbolize_keys.merge(public_urls_only: !ENV['INTEGRATION_TEST'])
    traits[branch_or_module_name] = prime_code_location.try(:branch_name)
    @source_scm ||= source_scm_class.new(traits)
  end

  def source_scm_class
    OhlohScm::Adapters::AbstractAdapter
  end

  # Allows testing/development to skip validation.
  def bypass_url_validation=(value)
    modified_value = value == '0' ? false : value.present?
    @bypass_url_validation = modified_value
  end

  def create_enlistment_for_project(editor_account, project, ignore = nil)
    enlistment = Enlistment.where(project_id: project.id, repository_id: id).first_or_initialize
    transaction do
      enlistment.editor_account = editor_account
      enlistment.assign_attributes(ignore: ignore)
      enlistment.save
      CreateEdit.find_by(target: enlistment).redo!(editor_account) if enlistment.deleted
    end
    enlistment.reload
  end

  def branch_or_module_name
    :branch_name
  end

  def prime_code_location_attributes=(traits)
    traits[:repository] = self
    super(traits)
  end

  class << self
    def find_existing(repository)
      branch_name = repository.prime_code_location.try(:branch_name)
      joins(:prime_code_location).order(:id).find_by(url: repository.url, code_locations: { branch_name: branch_name })
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

  def set_repository_id_for_prime_code_location
    prime_code_location.update_attribute :repository_id, id
  end
end
