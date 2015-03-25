class Project < ActiveRecord::Base
  include ProjectAssociations
  include LinkAccessors
  include Tsearch
  include ProjectSearchables

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
                                         :description, :tag_list, :missing_source, :url, :download_url],
                   merge_within: 30.minutes
  acts_as_protected
  link_accessors accessors: { url: :Homepage, download_url: :Download }

  validates :name, presence: true, length: 1..100, allow_nil: false, uniqueness: true, case_sensitive: false
  validates :description, length: 0..800, allow_nil: true # , if: proc { |p| p.validate_url_name_and_desc == 'true' }
  validates_each :url, :download_url, allow_blank: true do |record, field, value|
    record.errors.add(field, I18n.t(:not_a_valid_url)) unless value.valid_http_url?
  end
  before_validation :clean_strings_and_urls

  attr_accessor :managed_by_creator

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

  def users(query = '', sort = '')
    search_term = query.present? ? ['accounts.name iLIKE ?', "%#{query}%"] : nil
    orber_by = sort.eql?('name') ? 'accounts.name ASC' : 'people.kudo_position ASC'

    Account.select('DISTINCT(accounts.id), accounts.*, people.kudo_position')
      .joins([{ stacks: :stack_entries }, :person])
      .where(stack_entries: { project_id: id })
      .where(search_term)
      .order(orber_by)
  end

  def code_published_in_code_search?
    koders_status.try(:ohloh_code_ready) == true
  end

  private

  def clean_strings_and_urls
    self.name = String.clean_string(name)
    self.description = String.clean_string(description)
  end

  def sanitize(sql)
    Project.send :sanitize_sql, sql
  end
end
