class HomeDecorator
  def most_popular_projects
    Project.active.by_popularity.includes(:logo, best_analysis: [:main_language]).limit(10)
  end

  def most_active_projects
    ids = Rails.cache.fetch('HomeDecorator-most_active_projects-cache', expires_in: 1.day) do
      Project.most_active.includes(:logo, best_analysis: [:main_language, :thirty_day_summary]).map(&:id)
    end
    includes = [:logo, best_analysis: [:main_language, :thirty_day_summary]]
    Project.includes(includes).find(ids).index_by(&:id).slice(*ids).values
  end

  def most_active_contributors
    Account.recently_active.includes(best_vita: [:name_fact])
  end

  def commit_count
    projects = most_active_projects
    map = projects.map do |project|
      project.best_analysis.thirty_day_summary.commits_count if project.best_analysis.present?
    end
    map.compact
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

  def active_project_count
    Rails.cache.fetch('HomeDecorator-active_project_count-cache') { Project.active.count }
  end

  def person_count
    Rails.cache.fetch('HomeDecorator-person_count-cache') { Person.count }
  end

  def repository_count
    Rails.cache.fetch('HomeDecorator-repository_count-cache') do
      # TODO: Replace this repositories table call.
      Enlistment.connection.execute('select count(*) from repositories').values[0][0].to_i
    end
  end
end
