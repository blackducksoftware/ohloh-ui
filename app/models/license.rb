# frozen_string_literal: true

class License < ApplicationRecord
  include ActsAsEditable
  include ActsAsProtected

  validates :vanity_url, uniqueness: { case_sensitive: false }, length: { in: 2..50 },
                         default_param_format: true
  validates :name, uniqueness: { case_sensitive: false }, length: { in: 1..100 },
                   format: { without: Patterns::BAD_NAME }
  validates :description, length: { maximum: 50_000 }, allow_nil: true
  validates :url, url_format: true, allow_blank: true

  acts_as_editable editable_attributes: %i[vanity_url name description url],
                   merge_within: 30.minutes
  acts_as_protected

  filterable_by ['licenses.vanity_url', 'licenses.description', 'licenses.url', 'licenses.name']

  has_many :license_license_permissions
  has_many :license_permissions, through: :license_license_permissions, dependent: :destroy
  scope :active, -> { where(deleted: false) }
  scope :by_vanity_url, -> { order(:vanity_url) }
  scope :from_param, ->(vanity_url) { where(vanity_url: vanity_url) }
  scope :resolve_vanity_url, ->(vanity_url) { where('lower(vanity_url) = ?', vanity_url.downcase) }

  after_update :undo_redo_project_licenses, if: ->(license) { license.saved_change_to_deleted? }

  def to_param
    vanity_url
  end

  def allow_undo_to_nil?(key)
    %i[vanity_url name].exclude?(key)
  end

  def allow_edit?
    editor_account && (editor_account.access.admin? || !locked)
  end

  def short_name
    vanity_url.presence || name
  end

  def permitted_license_permissions
    license_permissions.merge(LicensePermission.Permitted)
  end

  def forbidden_license_permissions
    license_permissions.merge(LicensePermission.Forbidden)
  end

  def required_license_permissions
    license_permissions.merge(LicensePermission.Required)
  end

  class << self
    def autocomplete(term)
      License.active.select(%i[name id]).where(['lower(name) LIKE ?', "#{term.downcase}%"]).limit(10)
    end
  end

  private

  def undo_redo_project_licenses
    action = deleted? ? 'undo_project_licenses' : 'redo_project_licenses'
    project_licenses = ProjectLicense.where(license_id: id)
    send(action, project_licenses)
  end

  def undo_project_licenses(project_licenses)
    project_licenses.each do |pl|
      pl.edits.not_undone.each { |edit| edit.undo!(Account.hamster) }
    end
  end

  def redo_project_licenses(project_licenses)
    project_licenses.each do |pl|
      pl.edits.undone_by_hamster.each { |edit| edit.redo!(Account.hamster) }
    end
  end
end
