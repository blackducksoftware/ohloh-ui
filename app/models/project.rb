# rubocop:disable Metrics/ClassLength
class Project < ActiveRecord::Base
  has_many :links, -> { where(deleted: false) }
  has_one :permission, as: :target
  has_many :analyses
  has_many :analysis_summaries, through: :analyses
  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings
  belongs_to :best_analysis, foreign_key: :best_analysis_id, class_name: :Analysis
  has_many :aliases, -> { where { deleted.eq(false) & preferred_name_id.not_eq(nil) } }
  has_many :aliases_with_positions_name, -> { where { deleted.eq(false) & preferred_name_id.eq(positions.name_id) } },
           class_name: 'Alias'
  has_many :contributions
  has_many :positions
  has_many :stack_entries, -> { where { deleted_at.eq(nil) } }
  has_many :stacks, -> { where { deleted_at.eq(nil) & account_id.not_eq(nil) } }, through: :stack_entries
  belongs_to :logo
  belongs_to :organization
  has_many :manages, -> { where(deleted_at: nil, deleted_by: nil) }, as: 'target'
  has_many :managers, through: :manages, source: :account
  has_many :reviews
  has_many :ratings
  has_one :koders_status
  has_many :enlistments, -> { where(deleted: false) }
  has_many :repositories, through: :enlistments
  has_many :project_licenses, -> { where(deleted: false) }
  has_many :licenses, -> { order('lower(licenses.nice_name)') }, through: :project_licenses
  has_one :is_a_duplicate, class_name: 'Duplicate', foreign_key: 'bad_project_id'
  has_many :named_commits, ->(proj) { where(analysis_id: (proj.best_analysis_id || 0)) }
  has_many :commit_flags, -> { order(time: :desc).where('commit_flags.sloc_set_id = named_commits.sloc_set_id') },
           through: :named_commits
  scope :active, -> { where { deleted.not_eq(true) } }
  scope :deleted, -> { where(deleted: true) }
  scope :from_param, ->(id) { Project.where(Project.arel_table[:url_name].eq(id).or(Project.arel_table[:id].eq(id))) }
  scope :not_deleted, -> { where(deleted: false) }
  scope :been_analyzed, -> { where.not(best_analysis_id: nil) }
  scope :recently_analyzed, -> { not_deleted.been_analyzed.order(created_at: :desc) }
  scope :hot, ->(l_id = nil) { Project.not_deleted.been_analyzed.joins(:analyses).merge(Analysis.fresh_and_hot(l_id)) }
  scope :by_popularity, -> { where.not(user_count: 0).order(user_count: :desc) }
  scope :by_activity, -> { joins(:analyses).joins(:analysis_summaries).by_popularity.thirty_day_summaries }
  scope :by_new, -> { order(created_at: :desc) }
  scope :by_users, -> { order(user_count: :desc) }
  scope :by_rating, -> { order('COALESCE(rating_average,0) DESC, user_count DESC, projects.created_at ASC') }
  scope :by_activity_level, -> { order('COALESCE(activity_level_index,0) DESC, projects.name ASC') }
  scope :by_active_committers, -> { order('COALESCE(active_committers,0) DESC, projects.created_at ASC') }
  scope :by_project_name, -> { order(name: :asc) }
  scope :language, -> { joins(best_analysis: :main_language).select('languages.name').map(&:name).first }
  scope :managed_by, lambda { |account|
    joins(:manages).where.not(deleted: true, manages: { approved_by: nil }).where(manages: { account_id: account.id })
  }
  scope :case_insensitive_name, ->(mixed_case) { where(['lower(name) = ?', mixed_case.downcase]) }

  fix_string_column_encodings!

  acts_as_editable editable_attributes: [:name, :url_name, :logo_id, :organization_id, :best_analysis_id,
                                         :description, :tag_list, :missing_source], # TODO: add :url and :download_url
                   merge_within: 30.minutes
  acts_as_protected

  validates :name, presence: true, length: 1..100, allow_nil: false, uniqueness: true, case_sensitive: false
  validates :description, length: 0..800, allow_nil: true # , if: proc { |p| p.validate_url_name_and_desc == 'true' }
  # TODO: When Links are merged
  # validates_each :url, :download_url, allow_blank: true do |record, field, value|
  #   record.errors.add field, 'not a valid url' unless UrlValidation.valid_http_url?(value)
  # end
  before_validation :clean_strings_and_urls

  def to_param
    url_name || id.to_s
  end

  def related_by_stacks(limit = 12)
    stack_weights = StackEntry.stack_weight_sql(id)
    Project.select('projects.*, shared_stacks, shared_stacks*sqrt(shared_stacks)/projects.user_count as value')
      .joins(sanitize("INNER JOIN (#{stack_weights}) AS stack_weights ON stack_weights.project_id = projects.id"))
      .not_deleted.where('shared_stacks > 2').order('value DESC, shared_stacks DESC').limit(limit)
  end

  def related_by_tags(limit = 5)
    tag_weights = Tagging.tag_weight_sql(self.class, tags.map(&:id))
    Project.select('projects.*, tag_weights.weight')
      .joins(sanitize("INNER JOIN (#{tag_weights}) AS tag_weights ON tag_weights.project_id = projects.id"))
      .not_deleted.where.not(id: id).order('tag_weights.weight DESC, projects.user_count DESC').limit(limit)
  end

  def active_managers
    Manage.projects.for_target(self).active.to_a.map(&:account)
  end

  def allow_undo_to_nil?(key)
    ![:name].include?(key)
  end

  def allow_redo?(key)
    (key == :organization_id && !organization_id.nil?) ? false : true
  end

  def main_language
    return if best_analysis.nil? || best_analysis.main_language.nil?
    best_analysis.main_language.name
  end

  def best_analysis
    super || NilAnalysis.new
  end

  def users
    Account.select('DISTINCT(accounts.id), accounts.*, people.kudo_position')
      .joins(stacks: :stack_entries).joins(:person)
      .where(stack_entries: { project_id: id })
  end

  private

  def clean_strings_and_urls
    self.name = String.clean_string(name)
    self.description = String.clean_string(description)
    # TODO: fix these once we have links implemented
    # self.url = String.clean_url(url)
    # self.download_url = String.clean_url(download_url)
  end

  def sanitize(sql)
    Project.send :sanitize_sql, sql
  end
end
# rubocop:enable Metrics/ClassLength
