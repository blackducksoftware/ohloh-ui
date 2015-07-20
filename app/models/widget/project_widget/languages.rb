class ProjectWidget::Languages < ProjectWidget
  def title
    I18n.t('project_widgets.project_languages.title')
  end

  def height
    210
  end

  def width
    350
  end

  def position
    4
  end
end
