class Position < ActiveRecord::Base
  has_one :contribution
  belongs_to :account
	belongs_to :affiliation, class_name: 'Organization', foreign_key: :organization_id
  belongs_to :project
  belongs_to :name

  # FIXME: Replace account.has_claimed_positions? with account.positions.claimed.any?
  # FIXME: Replace account.claimed_positions with account.positions.claimed
  scope :claimed, -> { where { name_id.not_eq(nil) } }
  scope :claimed_by, -> account { where { account_id.eq(account.id) & name_id.not_eq(nil) } }

  class << self
    # FIXME: Replace account.active_positions with account.positions.active
    def active
      '
      EXISTS (SELECT * FROM name_facts
        INNER JOIN projects
          ON projects.best_analysis_id = name_facts.analysis_id
          AND name_facts.name_id = positions.name_id
          AND projects.id = positions.project_id)
      '
    end
  end
end
