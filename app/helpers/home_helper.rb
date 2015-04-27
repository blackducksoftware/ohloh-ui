module HomeHelper
  def width(project, required, max)
    count = project_count(project, required)
    max = 1 if max.to_i.zero?
    [1, count.to_i * 60 / max].max
  end

  def project_count(project, required)
    case required
    when 'most_popular_projects'
      return project.user_count
    when 'most_active_projects'
      return project.best_analysis.thirty_day_summary.commits_count unless project.best_analysis.nil?
    when 'most_active_contributors'
      # FIXME: Implement or replace project.best_vita and unstub the tests.
      project.best_vita.vita_fact.thirty_day_commits unless project.best_vita.vita_fact.nil?
    end
  end

  def set_link(project)
    if project.is_a?(Account)
      # FIXME: Implement avatar_img_path and unstub the tests.
      link_to(image_tag(avatar_img_path(project), height: 32, width: 32), account_path(project), class: 'top_ten_icon')
    else
      # FIXME: Implement capture_haml and unstub the tests.
      link_to(capture_haml { project_icon(project) }, project_path(project), class: 'top_ten_icon')
    end
  end

  def set_path(project)
    path = project.is_a?(Account) ? account_path(project) : project_path(project)
    # FIXME: Implement this `h` method and unstub the tests.
    link_to(h(project.name), path)
  end
end
