class Project < ActiveRecord::Base
  has_one :permission, as: :target
  belongs_to :logo
  has_many :stack_entries#, -> { where { deleted_at.eq(nil) } }
  has_many :stacks, through: :stack_entries#, -> { where { deleted_at.eq(nil) & account_id.not_eq(nil) } }, through: :stack_entries
  has_many :positions

  scope :active, -> { where { deleted.not_eq(true) } }

  def to_param
    url_name
  end

  def active_managers
    Manage.for_project(self).active.to_a
  end
end
