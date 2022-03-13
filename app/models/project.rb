# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Project < ApplicationRecord
  has_one :create_edit, as: :target
  acts_as_editable editable_attributes: %i[name vanity_url organization_id best_analysis_id
                                           description tag_list missing_source url download_url],
                   merge_within: 30.minutes

  include ProjectAssociations
  include LinkAccessors
  include Tsearch
  include ProjectSearchables
  include ProjectScopes
  include ProjectJobs
  include KnowledgeBaseCallbacks

  acts_as_protected
  acts_as_taggable
  link_accessors accessors: { url: :Homepage, download_url: :Download }

  validates :name, presence: true, length: 1..100, allow_nil: false, uniqueness: { case_sensitive: false }
  validates :vanity_url, presence: true, length: 1..60, allow_nil: false, uniqueness: { case_sensitive: false },
                         default_param_format: true
  validates :description, length: 0..800, allow_nil: true # , if: proc { |p| p.validate_vanity_url_and_desc == 'true' }
  validates_each :url, :download_url, allow_blank: true do |record, field, value|
    record.errors.add(field, I18n.t(:not_a_valid_url)) unless value.blank? || value.valid_http_url?
  end
  before_validation :clean_strings_and_urls
  after_update :remove_people, if: ->(project) { project.saved_change_to_deleted? && project.deleted? }
  after_update :recalc_tags_weight!, if: ->(project) { project.saved_change_to_deleted? }
  after_save :update_organzation_project_count

  attr_accessor :managed_by_creator

  def to_param
    vanity_url.presence || id.to_s
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
    Account.where(id: Manage.projects.for_target(self).active.select(:account_id))
  end

  def allow_undo_to_nil?(key)
    %i[vanity_url name].exclude?(key)
  end

  def allow_redo?(key)
    key == :organization_id && !organization_id.nil? ? false : true
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
           .where('level >= 0')
           .where(search_term)
           .order(orber_by)
  end

  def newest_contributions
    contributions.sort_by_newest.joins(:contributor_fact)
                 .preload(person: :account, contributor_fact: :primary_language).limit(10)
  end

  def top_contributions
    contributions.sort_by_twelve_month_commits.joins(:contributor_fact)
                 .preload(person: :account, contributor_fact: :primary_language).limit(10)
  end

  def badges_summary
    badges = travis_badges.active.first(2) + cii_badges.active.first(2)
    [badges[0], badges[2] || badges[1]].compact
  end

  def after_undo(current_user)
    remove_enlistments(current_user)
  end

  class << self
    def search_and_sort(query, sort, page)
      sort_by = sort == 'relevance' ? nil : "by_#{sort}"
      tsearch(query, sort_by)
        .includes(:best_analysis)
        .paginate(page: page, per_page: 20)
    end
  end

  private

  def clean_strings_and_urls
    self.name = String.clean_string(name)
    self.description = String.clean_string(description)
  end

  def sanitize(sql)
    Project.send :sanitize_sql, sql
  end

  def update_organzation_project_count
    org = Organization.find_by(id: organization_id || organization_id_before_last_save)
    return unless org

    org.update(editor_account: editor_account, projects_count: org.projects.count)
  end

  def remove_people
    Person.where(project_id: id).destroy_all
  end

  def remove_enlistments(current_user)
    enlistments.each do |enlistment|
      enlistment.create_edit.undo!(current_user) if enlistment.create_edit.allow_undo?
    end
  end

  def recalc_tags_weight!
    tags.each(&:recalc_weight!)
  end
end
# rubocop:enable Metrics/ClassLength
