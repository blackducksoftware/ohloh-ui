class HomeDecorator
  def most_popular_projects
    Project.active.by_popularity.includes(:logo, best_analysis: [:main_language]).limit(10)
  end

  def most_active_projects
    ids = Rails.cache.fetch 'HomeDecorator-most_active_projects-cache' do
      Project.most_active.includes(:logo, best_analysis: [:main_language, :thirty_day_summary]).map(&:id)
    end
    includes = [:logo, best_analysis: [:main_language, :thirty_day_summary]]
    Project.includes(includes).find(ids).index_by(&:id).slice(*ids).values
  end

  def most_active_contributors
    RecentlyActiveAccountsCache.accounts
  end

  def commit_count
    projects = most_active_projects
    projects.map do |project|
      project.best_analysis.thirty_day_summary.commits_count if project.best_analysis.present?
    end
  end

  def vita_count
    contributors = most_active_contributors
    contributors.map do |contributor|
      contributor.best_vita.name_fact.thirty_day_commits if contributor.best_vita
    end
  end

  def lines_count
    Language.pluck(:code, :comments, :blanks).flatten.sum
  end
end
