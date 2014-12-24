class Project < ActiveRecord::Base
  has_one :permission, as: :target
  has_many :aliases, -> { where { deleted.eq(false) & preferred_name_id.not_eq(nil) } }
  has_many :aliases_with_positions_name, -> { where { deleted.eq(false) & preferred_name_id.eq(positions.name_id) } },
           class_name: 'Alias'
  has_many :contributions
  has_many :positions
  has_many :stack_entries, -> { where { deleted_at.eq(nil) } }
  has_many :stacks, -> { where { deleted_at.eq(nil) & account_id.not_eq(nil) } }, through: :stack_entries
  belongs_to :logo
  belongs_to :best_analysis, foreign_key: :best_analysis_id, class_name: :Analysis
  belongs_to :organization

  scope :active, -> { where { deleted.not_eq(true) } }
  scope :deleted, -> { where(deleted: true) }

  def to_param
    url_name
  end

  def active_managers
    Manage.for_project(self).active.to_a
  end

  # TODO: Replace account.review(project) with project.first_review_for(account)
  def first_review_for(account)
    Review.where(account_id: account.id, project_id: id).first
  end
end
