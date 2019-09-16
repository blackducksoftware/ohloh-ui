# frozen_string_literal: true

class ProjectLicense < ActiveRecord::Base
  belongs_to :project
  belongs_to :license

  acts_as_editable
  acts_as_protected parent: :project

  validates :license_id, presence: true,
                         uniqueness: { scope: :project_id }
  validates :license_id, numericality: { greater_than: 0 }

  def allow_redo?(_key)
    license.deleted? ? false : true
  end
end
