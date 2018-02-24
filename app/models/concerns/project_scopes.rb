module ProjectScopes
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where.not(deleted: true) }
    scope :deleted, -> { where("projects.deleted = 't'") }
    scope :not_deleted, -> { where("projects.deleted = 'f'") }
    scope :from_param, lambda { |param|
      not_deleted.by_vanity_url_or_id(param)
    }
    scope :by_vanity_url_or_id, ->(param) { where('lower(vanity_url) = ? OR id = ?', param.to_s.downcase, param.to_i) }
    scope :been_analyzed, -> { where.not(best_analysis_id: nil) }
    scope :recently_analyzed, -> { not_deleted.been_analyzed.order(created_at: :desc) }
    scope :hot, lambda { |l_id = nil|
      not_deleted.joins(:best_analysis).merge(Analysis.fresh_and_hot(l_id))
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
    scope :case_insensitive_vanity_url, ->(mixed_case) { where(['lower(vanity_url) = ?', mixed_case.downcase]) }
    scope :most_active, lambda {
      joins(best_analysis: :analysis_summaries)
        .where(analysis_summaries: { type: 'ThirtyDaySummary' })
        .active
        .order(' COALESCE(analysis_summaries.affiliated_commits_count, 0) +
                 COALESCE(analysis_summaries.outside_commits_count, 0) DESC ')
        .limit(10)
    }
    scope :with_pai_available, -> { active.where(arel_table[:activity_level_index].gt(0)).size }
    scope :tagged_with, lambda { |tags|
      not_deleted.joins(:tags)
                 .where(tags: { name: tags })
                 .group('projects.id')
                 .having('count(*) >= ?', tags.split.flatten.length)
    }
    scope :with_analysis, -> { active.where.not(best_analysis_id: nil) }
    scope :active_enlistments, -> { active.joins(:enlistments).where(enlistments: { deleted: false }) }
  end
end
