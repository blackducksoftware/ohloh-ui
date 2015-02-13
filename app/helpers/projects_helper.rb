module ProjectsHelper
  def project_activity_level_class(project, image_size)
    haml_tag :a, href: 'http://blog.openhub.net/about-project-activity-icons/', target: '_blank',
                 class: project_activity_css_class(project, image_size),
                 title: project_activity_text(project, true)
  end

  def project_activity_css_class(project, size)
    "#{size}_project_activity_level_#{project_activity_level(project)}"
  end

  def project_activity_text(project, append_activity)
    activity_level = project_activity_level(project)
    case activity_level
    when :na then (append_activity ? "#{t('projects.activity')} " : '') + t('projects.not_available')
    when :new then t('projects.new_project')
    when :inactive then t('projects.inactive')
    else
      t("projects.#{activity_level}") + (append_activity ? " #{t('projects.activity')}" : '')
    end
  end

  private

  def project_activity_level(project)
    (project && project.best_analysis) ? project.best_analysis.activity_level : :na
  end
end
