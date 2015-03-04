module ProjectsHelper
  def project_activity_level_class(project, image_size)
    haml_tag :a, href: 'http://blog.openhub.net/about-project-activity-icons/', target: '_blank',
                 class: project_activity_css_class(project, image_size),
                 title: project_activity_text(project, true)
  end

  def project_activity_level_text(project, image_size)
    haml_tag :div, project_activity_text(project, true), class: project_activity_level_text_class(image_size)
  end

  def project_metric_from_sort(sort)
    case sort
    when 'by_new'
      :created_at
    when 'by_rating'
      :rating_average
    else
      :users
    end
  end

  def project_iusethis_button(project)
    haml_tag :a, href: '#', id: "stackit_#{project.to_param}",
                 class: "#{logged_in? ? 'stack_trigger' : 'needs_login'} dontnav btn btn-primary btn-mini" do
      concat t('projects.i_use_this')
    end
  end

  def project_description(project)
    description(project.description.truncate(340), t('projects.more'), style: 'display: inline',
                                                                       id: "proj_desc_#{project.id}_sm",
                                                                       link_id: "proj_more_desc_#{project.id}",
                                                                       css_clazz: 'proj_desc_toggle')
    description(project.description, t('projects.less'), style: 'display: none',
                                                         id: "proj_desc_#{project.id}_lg",
                                                         link_id: "proj_less_desc_#{project.id}",
                                                         css_clazz: 'proj_desc_toggle')
  end

  def project_compare_button(project, label = project.name)
    selected = (@session_projects || []).include?(project)
    haml_tag :form, class: "sp_form styled form-inline #{'selected' if selected}",
                    style: 'min-width: 94px;', id: "sp_form_#{project.to_param}" do
      haml_tag :span, class: 'sp_label', title: label do
        concat label.truncate(35)
      end
      haml_tag :input, style: 'margin-top: 2px;', type: 'checkbox', id: "sp_chk_#{project.to_param}",
                       checked: selected, project_id: project.to_param, class: 'sp_input'
      haml_tag :div, class: 'clear_both'
    end
  end

  private

  def project_activity_css_class(project, size)
    "#{size}_project_activity_level_#{project_activity_level(project)}"
  end

  def project_activity_level_text_class(image_size)
    "#{image_size}_project_activity_text"
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
