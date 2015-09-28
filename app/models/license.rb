class License < ActiveRecord::Base
  validates :vanity_url, uniqueness: { case_sensitive: false }, length: { in: 2..50 },
                         default_param_format: true
  validates :name, uniqueness: { case_sensitive: false }, length: { in: 1..100 }
  validates :abbreviation, length: {  maximum: 100 }, allow_nil: true
  validates :description, length: { maximum: 50_000 }, allow_nil: true
  validates :url, url_format: true, allow_blank: true

  acts_as_editable editable_attributes: [:vanity_url, :name, :abbreviation, :description, :url],
                   merge_within: 30.minutes
  acts_as_protected

  filterable_by ['licenses.vanity_url', 'licenses.description', 'licenses.url', 'licenses.abbreviation',
                 'licenses.name']

  scope :active, -> { where(deleted: false) }
  scope :by_vanity_url, -> { order(:vanity_url) }
  scope :from_param, ->(vanity_url) { where(vanity_url: vanity_url) }
  scope :resolve_vanity_url, ->(vanity_url) { where('lower(vanity_url) = ?', vanity_url.downcase) }

  def to_param
    vanity_url
  end

  def allow_undo_to_nil?(key)
    ![:vanity_url, :name].include?(key)
  end

  def allow_edit?
    editor_account && (editor_account.access.admin? || !locked)
  end

  def short_name
    abbreviation.blank? ? name : abbreviation
  end

  class << self
    def autocomplete(term)
      License.active.select([:name, :id]).where(['lower(name) LIKE ?', "#{term.downcase}%"]).limit(10)
    end
  end
end
