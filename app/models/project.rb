class Project < ActiveRecord::Base
  has_one :permission, as: :target
  has_many :analyses
  has_many :analysis_summaries, through: :analyses
  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings
  belongs_to :best_analysis, foreign_key: 'best_analysis_id', class_name: 'Analysis'
  belongs_to :logo

  validates :name, presence: true, length: 1..100, allow_nil: false, if: proc { |p| !p.name.blank? },
                   uniqueness: true, case_sensitive: false
  validates :description, length: 0..800, allow_nil: true, if: proc { |p| p.validate_url_name_and_desc == 'true' }
  validates_each :url, :download_url, allow_blank: true do |record, field, value|
    record.errors.add field, 'not a valid url' unless UrlValidation.valid_http_url?(value)
  end
  before_validation :clean_strings_and_urls

  scope :not_deleted, -> { where(deleted: false) }
  scope :been_analyzed, -> { where.not(best_analysis_id: nil) }
  scope :recently_analyzed, -> { not_deleted.been_analyzed.order(created_at: :desc) }
  scope :matching, ->(other) { matching_arel(other).not_deleted }
  scope :case_insensitive_match, ->(project, attribute) { case_insensitive_match_arel(project, attribute) }
  scope :hot, ->(lang_id) { hot_projects(lang_id) }
  scope :by_popularity, -> { where.not(user_count: 0).order(user_count: :desc) }
  scope :by_activity, -> { joins(:analyses).joins(:analysis_summaries).by_popularity.thirty_day_summaries }

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

  class << self
    def hot_projects(lang_id)
      hots = not_deleted.been_analyzed.analyses.fresh.hotness_scored
      hots = hots.for_lang(lang_id) unless lang_id.nil?
      hots
    end

    private

    def clean_string(str)
      return str if str.blank?
      str.strip.strip_tags
    end

    def clean_url(url)
      return url if url.blank?
      url.strip!
      (url =~ %r{^(http:/)|(https:/)|(ftp:/)}) ? url : "http://#{url}"
    end

    def matching_arel(other)
      case_insensitive_match(other, :owner_at_forge)
        .case_insensitive_match(other, :name_at_forge)
        .where(forge_id: other.forge_id)
    end

    def case_insensitive_match_arel(project, attribute)
      where(Project.arel_table[attribute].lower.eq((project.send(attribute) || '').downcase))
    end
  end

  private

  def clean_strings_and_urls
    self.name = Project.clean_string(name)
    self.description = Project.clean_string(description)
    self.url = Project.clean_url(url)
    self.download_url = Project.clean_url(download_url)
  end

  def sanitize(sql)
    Project.send :sanitize_sql, sql
  end
end
