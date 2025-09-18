# frozen_string_literal: true

class Widget::ProjectWidget::Factoids < Widget::ProjectWidget
  def title
    I18n.t('project_widgets.factoids.title')
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
