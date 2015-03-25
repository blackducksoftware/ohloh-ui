class ProjectWidget::BrowseCode < ProjectWidget
  def height
    205
  end

  def width
    350
  end

  def short_nice_name
    I18n.t('project_widgets.browse_code.short_nice_name')
  end

  def title
    I18n.t('project_widgets.browse_code.title')
  end

  def can_display?
    project.code_published_in_code_search?
  end

  def position
    5
  end
end
