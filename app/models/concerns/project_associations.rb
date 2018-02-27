module ProjectAssociations
  extend ActiveSupport::Concern

  included do
    has_many :links, -> { where("links.deleted = 'f'") }
    has_one :permission, as: :target
    has_many :analyses
    has_many :analysis_summaries, through: :analyses
    has_many :taggings, as: :taggable
    has_many :tags, through: :taggings
    has_many :project_badges, through: :enlistments
    has_many :travis_badges, through: :enlistments
    has_many :cii_badges, through: :enlistments
    belongs_to :best_analysis, foreign_key: :best_analysis_id, class_name: :Analysis
    belongs_to :best_project_security_set, foreign_key: :best_project_security_set_id, class_name: :ProjectSecuritySet
    has_many :aliases, -> { where(deleted: false).where.not(preferred_name_id: nil) }
    has_many :contributions
    has_many :positions
    has_many :stack_entries, -> { where(deleted_at: nil) }
    has_many :stacks, -> { where(deleted_at: nil).where.not(arel_table[:account_id].eq(nil)) }, through: :stack_entries
    belongs_to :logo
    belongs_to :organization
    has_many :manages, -> { where(deleted_at: nil, deleted_by: nil) }, as: 'target'
    has_many :managers, through: :manages, source: :account
    has_many :project_security_sets
    has_many :rss_subscriptions, -> { where(deleted: false) }
    has_many :rss_feeds, through: :rss_subscriptions
    has_many :reviews
    has_many :ratings
    has_many :kudos
    has_many :jobs
    belongs_to :forge, class_name: 'Forge::Base'
    has_many :enlistments, -> { where(deleted: false) }
    has_many :project_licenses, -> { where("project_licenses.deleted = 'f'") }
    has_many :licenses, -> { order('lower(licenses.name)') }, through: :project_licenses
    has_many :duplicates, -> { order(created_at: :desc) }, class_name: 'Duplicate', foreign_key: 'good_project_id'
    has_one :is_a_duplicate, -> { where.not(resolved: true) }, class_name: 'Duplicate', foreign_key: 'bad_project_id'
    has_many :analysis_sloc_sets, primary_key: :best_analysis_id, foreign_key: :analysis_id
    has_many :commit_flags, -> { order(time: :desc) }, through: :analysis_sloc_sets
    has_one :project_vulnerability_report
    has_many :commit_contributors
    accepts_nested_attributes_for :enlistments
    accepts_nested_attributes_for :project_licenses

    scope :by_collection, ->(ids, sort, query) { collection_arel(ids, sort, query) }

    attr_accessor :code_location_object

    def code_locations
      @code_locations ||= CodeLocationSubscription.code_locations_for_project(id)
    end

    def assign_editor_account_to_associations
      [aliases, enlistments, project_licenses, links].flatten.each { |obj| obj.editor_account = editor_account }
    end

    def rss_articles
      RssArticle.joins(rss_feed: :rss_subscriptions)
                .where("rss_subscriptions.project_id = #{id} and rss_subscriptions.deleted = false")
                .order('time DESC')
    end

    def contributions_within_timespan(options)
      contributions
        .within_timespan(options[:time_span], best_analysis.oldest_code_set_time)
        .sort(options[:sort])
        .filter_by(options[:query])
        .includes(person: :account, contributor_fact: :primary_language)
        .references(:all)
    end

    def stacks_count
      Stack.joins(:stack_entries, :account)
           .where(deleted_at: nil, stack_entries: { project_id: id })
           .where('accounts.level >= 0')
           .count('distinct(account_id)')
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
