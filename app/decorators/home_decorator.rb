class HomeDecorator
  def most_popular_projects
    Project.by_popularity.limit(10)
  end

  def most_active_projects
    Project.most_active
  end

  def most_active_contributors
    RecentlyActiveAccountsCache.accounts
  end

  def commit_count
    projects = most_active_projects
    projects.map do |project|
      project.best_analysis.thirty_day_summary.commits_count if project.best_analysis
    end
  end

  def vita_count
    contributors = most_active_contributors
    contributors.map do |contributor|
      contributor.best_vita.vita_fact.thirty_day_commits if contributor.best_vita
    end
  end

  def lines_count
    Language.sum(:code) + Language.sum(:comments) + Language.sum(:blanks)
  end
end
