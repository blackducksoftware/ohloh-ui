class Account < ActiveRecord::Base
  DEFAULT_LEVEL = 0
  ADMIN_LEVEL   = 10
  DISABLE_LEVEL = -10
  SPAMMER_LEVEL = -20

  oh_delegators :stack_extension, :organization_extension, :project_extension

  has_many :api_keys
  has_many :positions, -> { where("(positions.project_id IS NULL OR positions.project_id IN (SELECT projects.id FROM projects WHERE positions.project_id=projects.id AND NOT DELETED))") }
  belongs_to :organization

  def admin?
    level == ADMIN_LEVEL
  end
end
