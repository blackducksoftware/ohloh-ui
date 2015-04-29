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
    has_many :kudos
    has_one :koders_status
    has_many :enlistments, -> { where(deleted: false) }
    has_many :repositories, through: :enlistments
    has_many :project_licenses, -> { where(deleted: false) }
    has_many :licenses, -> { order('lower(licenses.nice_name)') }, through: :project_licenses
    has_many :duplicates, -> { order(created_at: :desc) }, class_name: 'Duplicate', foreign_key: 'good_project_id'
    has_one :is_a_duplicate, class_name: 'Duplicate', foreign_key: 'bad_project_id'
    has_many :named_commits, ->(proj) { where(analysis_id: (proj.best_analysis_id || 0)) }
    has_many :commit_flags, -> { order(time: :desc).where('commit_flags.sloc_set_id = named_commits.sloc_set_id') },
             through: :named_commits

    accepts_nested_attributes_for :enlistments
    accepts_nested_attributes_for :project_licenses

    scope :by_collection, ->(ids, sort, query) { collection_arel(ids, sort, query) }

    def assign_editor_account_to_associations
      [aliases, enlistments, project_licenses, links].flatten.each { |obj| obj.editor_account = editor_account }
    end

    class << self
      def collection_arel(ids = nil, sort = nil, query = nil)
        if !ids.blank?
          where(id: ids.split(',')).order(:id)
        else
          tsearch(query, respond_to?("by_#{sort}") ? "by_#{sort}" : nil)
        end
      end
    end
  end
end
