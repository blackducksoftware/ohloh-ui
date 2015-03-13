module ProjectAssociations
  extend ActiveSupport::Concern

  included do
    has_many :links, -> { where(deleted: false) }
    has_one :permission, as: :target
    has_many :analyses
    has_many :analysis_summaries, through: :analyses
    has_many :taggings, as: :taggable
    has_many :tags, through: :taggings
    belongs_to :best_analysis, foreign_key: :best_analysis_id, class_name: :Analysis
    has_many :aliases, -> { where { deleted.eq(false) & preferred_name_id.not_eq(nil) } }
    has_many :aliases_with_positions_name, -> { where { deleted.eq(false) & preferred_name_id.eq(positions.name_id) } },
             class_name: 'Alias'
    has_many :contributions
    has_many :positions
    has_many :stack_entries, -> { where { deleted_at.eq(nil) } }
    has_many :stacks, -> { where { deleted_at.eq(nil) & account_id.not_eq(nil) } }, through: :stack_entries
    belongs_to :logo
    belongs_to :organization
    has_many :manages, -> { where(deleted_at: nil, deleted_by: nil) }, as: 'target'
    has_many :managers, through: :manages, source: :account
    has_many :reviews
    has_many :ratings
    has_one :koders_status
    has_many :enlistments, -> { where(deleted: false) }
    has_many :repositories, through: :enlistments
    has_many :project_licenses, -> { where(deleted: false) }
    has_many :licenses, -> { order('lower(licenses.nice_name)') }, through: :project_licenses
  end
end
