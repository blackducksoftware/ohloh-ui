module HomeHelper
  def width(project, required, max)
    count = project_count(project, required)
    max = 1 if max.to_i.zero?
    [1, count.to_i * 60 / max].max
  end

  def project_count(item, required)
    case required
    when 'most_popular_projects'
      return item.user_count
    when 'most_active_projects'
      return item.best_analysis.thirty_day_summary.commits_count unless item.best_analysis.blank?
    when 'most_active_contributors'
      item.best_vita.vita_fact.thirty_day_commits unless item.best_vita.vita_fact.blank?
    end
  end

  def set_link(project)
    if project.is_a?(Account)
      link_to(image_tag(avatar_img_path(project), height: 32, width: 32), account_path(project), class: 'top_ten_icon')
    else
      link_to(capture_haml { project_icon(project) }, project_path(project), class: 'top_ten_icon')
    end
  end

  def set_path(project)
    path = project.is_a?(Account) ? account_path(project) : project_path(project)
    link_to(h(project.name), path)
  end

  def home_top_lists
    Rails.cache.fetch 'homepage_top_lists', expires_in: 6.hours do
      render partial: 'top_lists'
    end
  end
end
