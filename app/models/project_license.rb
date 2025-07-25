# frozen_string_literal: true

class ProjectLicense < ApplicationRecord
  include KnowledgeBaseCallbacks
  include ActsAsEditable
  include ActsAsProtected

  belongs_to :project, optional: true
  belongs_to :license, optional: true

  acts_as_editable
  acts_as_protected parent: :project

  validates :license_id, presence: true,
                         uniqueness: { scope: :project_id }
  validates :license_id, numericality: { greater_than: 0 }

  def allow_redo?(_key)
    !license.deleted?
  end
end
