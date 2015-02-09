class Organization < ActiveRecord::Base
  ORG_TYPES = { 'Commercial' => 1, 'Education' => 2, 'Government' => 3, 'Non-Profit' => 4 }

  belongs_to :logo
  has_one :permission, as: :target
  has_many :projects, -> { where.not(deleted: true) }
  has_many :accounts, -> { where(Account.arel_table[:level].gteq(0)) }
  has_many :manages, -> { where(deleted_at: nil, deleted_by: nil) }, as: 'target'
  has_many :managers, through: :manages, source: :account

  scope :from_param, ->(param) { where(url_name: param) }
  scope :active, -> { where.not(deleted: true) }

  validates :name, presence: true, length: 3..85, uniqueness: { case_sensitive: false }
  validates :description, length: 0..800, allow_nil: true
  validates :org_type, inclusion: { in: ORG_TYPES.values }
  before_validation :clean_strings_and_urls

  acts_as_editable editable_attributes: [:name, :url_name, :org_type, :logo_id, :description, :homepage_url],
                   merge_within: 30.minutes
  acts_as_protected

  after_create :create_restricted_permission

  def to_param
    url_name
  end

  def active_managers
    Manage.organizations.for_target(self).active.to_a.map(&:account)
  end

  def allow_undo?(key)
    ![:name, :org_type].include?(key)
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

  private

  def create_restricted_permission
    Permission.create(target: self, remainder: true)
  end

  def clean_strings_and_urls
    self.name = String.clean_string(name)
    self.description = String.clean_string(description)
    # TODO: fix these once we have links implemented
    # self.download_url = String.clean_url(download_url)
  end
end
