class Repository < ActiveRecord::Base
  belongs_to :best_code_set, foreign_key: :best_code_set_id, class_name: CodeSet
  belongs_to :forge, class_name: "Forge::Base"
  has_many :enlistments, -> { not_deleted }
  has_many :projects, through: :enlistments
  has_many :jobs

  scope :matching, ->(match) { Repository.forge_match_search(match) }

  validates :url, presence: true
  validates :branch_name, length: { maximum: 80 },
                          format: { with: /\A[A-Za-z0-9_^\-\+\.\/\ ]+\Z/ },
                          allow_blank: true
  validates :username, length: { maximum: 32 },
                       format: { with: /\A\w*\Z/ },
                       allow_blank: true
  validates :password, length: { maximum: 32 },
                       format: { with: /\A[\w!@\#$%^&*\(\)\{\}\[\]\;\?\|\+\-\=]*\Z/ },
                       allow_blank: true

  attr_accessor :forge_match

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

  def ensure_job(priority = 0)
    job = nil
    Job.transaction do
      job = jobs.incomplete.first
      return job if job
      job = create_fetch_job(priority) if best_code_set.blank?
      job = create_import_or_sloc_jobs(priority) if best_code_set.present?
    end
    job
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

  def create_fetch_job(priority)
    cs = CodeSet.create(repository: self)
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
