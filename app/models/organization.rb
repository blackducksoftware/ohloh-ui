class Organization < ActiveRecord::Base
  include OrganizationSearchables
  include OrganizationJobs
  include Tsearch

  ORG_TYPES = { 'Commercial' => 1, 'Education' => 2, 'Government' => 3, 'Non-Profit' => 4 }
  ALLOWED_SORT_OPTIONS = %w(newest recent name projects)

  belongs_to :logo
  has_one :permission, as: :target
  has_many :projects, -> { where.not(deleted: true) }
  has_many :accounts, -> { where(Account.arel_table[:level].gteq(0)) }
  has_many :manages, -> { where(deleted_at: nil, deleted_by: nil) }, as: 'target'
  has_many :managers, through: :manages, source: :account
  has_many :jobs
  has_many :organization_jobs

  scope :from_param, lambda { |param|
    active.where(Organization.arel_table[:url_name].eq(param).or(Organization.arel_table[:id].eq(param)))
  }
  scope :active, -> { where.not(deleted: true) }
  scope :managed_by, lambda { |account|
    joins(:manages).where.not(deleted: true, manages: { approved_by: nil }).where(manages: { account_id: account.id })
  }
  scope :case_insensitive_url_name, ->(mixed_case) { where(['lower(url_name) = ?', mixed_case.downcase]) }
  scope :sort_by_newest, -> { order(created_at: :desc) }
  scope :sort_by_recent, -> { order(updated_at: :desc) }
  scope :sort_by_name, -> { order(arel_table[:name].lower) }
  scope :sort_by_projects, -> { order('COALESCE(projects_count, 0) DESC') }

  validates :name, presence: true, length: 3..85, allow_blank: true
  validates :homepage_url, allow_blank: true, url_format: { message: I18n.t('accounts.invalid_url_format') }
  validates :name, presence: true, length: 3..85, uniqueness: { case_sensitive: false }
  validates :url_name, presence: true, length: 1..60, allow_nil: false, uniqueness: { case_sensitive: false },
                       default_param_format: true
  validates :description, length: 0..800, allow_nil: true
  validates :org_type, inclusion: { in: ORG_TYPES.values }

  before_validation :clean_strings_and_urls

  acts_as_editable editable_attributes: [:name, :url_name, :org_type, :logo_id, :description, :homepage_url],
                   merge_within: 30.minutes
  acts_as_protected

  after_create :create_restricted_permission
  after_save :check_change_in_delete
  after_update :schedule_analysis, if: :org_type_changed?

  def to_param
    url_name.blank? ? id.to_s : url_name
  end

  def active_managers
    Manage.organizations.for_target(self).active.to_a.map(&:account)
  end

  def allow_undo_to_nil?(key)
    ![:name, :org_type].include?(key)
  end

  def org_type_label
    ORG_TYPES.invert[org_type] || ''
  end

  def affiliated_committers_stats
    Organization::Affiliated.new(self).stats
  end

  def affiliated_committers(page, limit)
    Organization::Affiliated.new(self).committers(page, limit)
  end

  def affiliated_projects(page, limit)
    Organization::Affiliated.new(self).projects(page, limit)
  end

  def outside_committers_stats
    Organization::Outside.new(self).stats
  end

  def outside_committers(page, limit)
    Organization::Outside.new(self).committers(page, limit)
  end

  def outside_projects(page, limit)
    Organization::Outside.new(self).projects(page, limit)
  end

  def projects_count
    projects.count(true)
  end

  def affiliators_count
    @affiliators_count ||=
      accounts.joins(:person, :positions)
      .where(NameFact.with_positions)
      .count('DISTINCT(accounts.id)')
  end

  class << self
    def search_and_sort(query, sort, page)
      sort = 'projects' unless sort && ALLOWED_SORT_OPTIONS.include?(sort)
      tsearch(query, "sort_by_#{sort}").where.not(deleted: true).paginate(page: page, per_page: 10)
    end
  end

  private

  def create_restricted_permission
    Permission.create(target: self, remainder: true)
  end

  def clean_strings_and_urls
    self.name = String.clean_string(name)
    self.description = String.clean_string(description)
    self.homepage_url = String.clean_url(homepage_url)
  end

  def project_claim_edits(undone)
    Edit.where(target_type: 'Project', key: 'organization_id', value: id.to_s, undone: undone).to_a
  end

  def check_change_in_delete
    return false unless changed.include?('deleted')
    project_claim_edits(!deleted?).each { |edit| edit.send(deleted? ? :undo! : :redo!, editor_account) }
    schedule_analysis
  end
end
