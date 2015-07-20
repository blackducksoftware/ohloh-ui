class ProjectWidget::FactoidsStats < ProjectWidget
  def height
    220
  end

  def width
    370
  end

  def short_nice_name
    I18n.t('project_widgets.project_factoids_stats.short_nice_name')
  end

  def title
    I18n.t('project_widgets.project_factoids_stats.title')
  end

  def position
    1
  end
end
