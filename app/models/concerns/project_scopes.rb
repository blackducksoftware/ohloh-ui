module ProjectScopes
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where { deleted.not_eq(true) } }
    scope :deleted, -> { where(deleted: true) }
    scope :not_deleted, -> { where(deleted: false) }
    scope :from_param, lambda { |param|
      not_deleted.where(Project.arel_table[:url_name].eq(param).or(Project.arel_table[:id].eq(param)))
    }
    scope :been_analyzed, -> { where.not(best_analysis_id: nil) }
    scope :recently_analyzed, -> { not_deleted.been_analyzed.order(created_at: :desc) }
    scope :hot, lambda { |l_id = nil|
      not_deleted.been_analyzed.joins(:analyses).merge(Analysis.fresh_and_hot(l_id))
    }
    scope :by_popularity, -> { where.not(user_count: 0).order(user_count: :desc) }
    scope :by_activity, -> { joins(:analyses).joins(:analysis_summaries).by_popularity.thirty_day_summaries }
    scope :by_new, -> { order(created_at: :desc) }
    scope :by_users, -> { order(user_count: :desc) }
    scope :by_rating, -> { order('COALESCE(rating_average,0) DESC, user_count DESC, projects.created_at ASC') }
    scope :by_activity_level, -> { order('COALESCE(activity_level_index,0) DESC, projects.name ASC') }
    scope :by_active_committers, -> { order('COALESCE(active_committers,0) DESC, projects.created_at ASC') }
    scope :by_project_name, -> { order(name: :asc) }
    scope :language, -> { joins(best_analysis: :main_language).select('languages.name').map(&:name).first }
    scope :managed_by, lambda { |account|
      joins(:manages).where.not(deleted: true, manages: { approved_by: nil }).where(manages: { account_id: account.id })
    }
    scope :case_insensitive_name, ->(mixed_case) { where(['lower(name) = ?', mixed_case.downcase]) }
    scope :case_insensitive_url_name, ->(mixed_case) { where(['lower(url_name) = ?', mixed_case.downcase]) }
    scope :most_active, lambda {
      joins(best_analysis: :analysis_summaries).where(analysis_summaries: { type: 'ThirtyDaySummary' })
        .active. order(' COALESCE(analysis_summaries.affiliated_commits_count, 0) +
                     COALESCE(analysis_summaries.outside_commits_count, 0) DESC ').limit(10)
    }
  end
end
