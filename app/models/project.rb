class Project < ActiveRecord::Base
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

  scope :active, -> { where { deleted.not_eq(true) } }
  scope :deleted, -> { where(deleted: true) }
  scope :from_param, ->(param) { where(url_name: param) }
  scope :not_deleted, -> { where(deleted: false) }
  scope :been_analyzed, -> { where.not(best_analysis_id: nil) }
  scope :recently_analyzed, -> { not_deleted.been_analyzed.order(created_at: :desc) }
  scope :hot, ->(lang_id) { hot_projects(lang_id) }
  scope :by_popularity, -> { where.not(user_count: 0).order(user_count: :desc) }
  scope :by_activity, -> { joins(:analyses).joins(:analysis_summaries).by_popularity.thirty_day_summaries }

  acts_as_editable editable_attributes: [:name, :url_name, :logo_id, :organization_id, :best_analysis_id,
                                         :description, :tag_list, :missing_source], # TODO: add :url and :download_url
                   merge_within: 30.minutes

  validates :name, presence: true, length: 1..100, allow_nil: false, if: proc { |p| !p.name.blank? },
                   uniqueness: true, case_sensitive: false
  validates :description, length: 0..800, allow_nil: true # , if: proc { |p| p.validate_url_name_and_desc == 'true' }
  # TODO: When Links are merged
  # validates_each :url, :download_url, allow_blank: true do |record, field, value|
  #   record.errors.add field, 'not a valid url' unless UrlValidation.valid_http_url?(value)
  # end
  before_validation :clean_strings_and_urls

  def to_param
    url_name
  end

  def related_by_stacks(limit = 12)
    stack_weights = StackEntry.stack_weight_sql(id)
    Project.select('projects.*, shared_stacks, shared_stacks*sqrt(shared_stacks)/projects.user_count as value')
      .joins(sanitize("INNER JOIN (#{stack_weights}) AS stack_weights ON stack_weights.project_id = projects.id"))
      .not_deleted
      .where('shared_stacks > 2')
      .order('value DESC, shared_stacks DESC')
      .limit(limit)
  end

  def related_by_tags(limit = 5)
    tag_weights = Tagging.tag_weight_sql(self.class, tags.map(&:id))
    Project.select('projects.*, tag_weights.weight')
      .joins(sanitize("INNER JOIN (#{tag_weights}) AS tag_weights ON tag_weights.project_id = projects.id"))
      .not_deleted
      .where.not(id: id)
      .order('tag_weights.weight DESC, projects.user_count DESC')
      .limit(limit)
  end

  def active_managers
    Manage.projects.for_target(self).active.to_a.map(&:account)
  end

  def allow_undo?(key)
    ![:name].include?(key)
  end

  def allow_redo?(key)
    (key == :organization_id && !organization_id.nil?) ? false : true
  end

  class << self
    def hot_projects(lang_id = nil)
      Project.not_deleted.been_analyzed.joins(:analyses).merge(Analysis.fresh_and_hot(lang_id))
    end
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
