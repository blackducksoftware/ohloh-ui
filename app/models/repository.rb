class Repository < ActiveRecord::Base
  belongs_to :best_code_set, foreign_key: :best_code_set_id, class_name: CodeSet
  has_many :enlistments, -> { not_deleted }
  has_many :projects, through: :enlistments
  has_many :jobs

  scope :matching, ->(match) { Repository.forge_match_search(match) }

  validates :url, presence: true
  validates :branch_name, length: { maximum: 80 },
                          format: { with: /\A[A-Za-z0-9_^\-\+\.\/\ ]+\Z/ }
  validates :username, length: { maximum: 32 },
                       format: { with: /\A\w*\Z/ }
  validates :password, length: { maximum: 32 },
                       format: { with: /\A[\w!@\#$%^&*\(\)\{\}\[\]\;\?\|\+\-\=]*\Z/ }

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
end
