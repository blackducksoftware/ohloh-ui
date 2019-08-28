# frozen_string_literal: true

class ProjectWidget::BasicStats < ProjectWidget
  def height
    225
  end

  def width
    350
  end

  def title
    I18n.t('project_widgets.basic_stats.title')
  end

  def position
    3
  end
end
