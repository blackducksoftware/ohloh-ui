class ProjectWidget::Factoids < ProjectWidget
  def title
    I18n.t('project_widgets.project_factoids.title')
  end

  def height
    175
  end

  def width
    350
  end

  def position
    2
  end
end
