class License < ActiveRecord::Base
  validates :name, uniqueness: { case_sensitive: false }, length: { in: 2..50 },
                   default_param_format: true
  validates :nice_name, uniqueness: { case_sensitive: false }, length: { in: 1..100 }
  validates :abbreviation, length: {  maximum: 100 }, allow_nil: true
  validates :description, length: { maximum: 50_000 }, allow_nil: true
  validates :url, url_format: true, allow_blank: true

  acts_as_editable editable_attributes: [:name, :nice_name, :abbreviation, :description, :url],
                   merge_within: 30.minutes
  acts_as_protected

  filterable_by ['licenses.name', 'licenses.description', 'licenses.url', 'licenses.abbreviation', 'licenses.nice_name']

  scope :by_name, -> { order(:name) }
  scope :from_param, ->(name) { where(name: name) }
  scope :resolve_name, ->(name) { where('lower(name) = ?', name.downcase) }

  default_scope { where(deleted: false) }

  def to_param
    name
  end

  def allow_undo_to_nil?(key)
    ![:name, :nice_name].include?(key)
  end

  def allow_edit?
    editor_account && (Account::Access.new(editor_account).admin? || !locked)
  end

  def short_name
    abbreviation.blank? ? nice_name : abbreviation
  end

  class << self
    def autocomplete(term)
      License.select([:nice_name, :id]).where(['lower(nice_name) LIKE ?', "#{term.downcase}%"]).limit(10)
    end
  end
end
