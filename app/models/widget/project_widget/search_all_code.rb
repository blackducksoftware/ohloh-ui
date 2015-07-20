class ProjectWidget::SearchAllCode < ProjectWidget
  def height
    130
  end

  def width
    350
  end

  def short_nice_name
    I18n.t('project_widgets.project_search_code.short_nice_name')
  end

  def title
    I18n.t('project_widgets.project_search_code.title')
  end

  def position
    7
  end
end
