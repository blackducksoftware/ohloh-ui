module ProjectsHelper
  def project_activity_level_class(project, image_size)
    haml_tag :a, href: 'http://blog.openhub.net/about-project-activity-icons/', target: '_blank',
                 class: project_activity_css_class(project, image_size),
                 title: project_activity_text(project, true)
  end

  private

  def project_activity_css_class(project, size)
    "#{size}_project_activity_level_#{project_activity_level(project)}"
  end

  def project_activity_text(project, append_activity)
    activity_level = project_activity_level(project)
    case activity_level
    when :na then "#{t('projects.activity') if append_activity} #{t('projects.not_available')}"
    when :new then t('projects.new_project')
    when :inactive then t('projects.inactive')
    else
      "#{t("projects.#{activity_level}")} #{t('projects.activity') if append_activity }"
    end
  end

  def project_activity_level(project)
    project.best_analysis.activity_level
  end
end
