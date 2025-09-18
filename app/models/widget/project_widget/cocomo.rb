# frozen_string_literal: true

class Widget::ProjectWidget::Cocomo < Widget::ProjectWidget
  def height
    205
  end

  def width
    350
  end

  def title
    I18n.t('project_widgets.cocomo.title')
  end

  def salary
    vars[:salary] || '55000'
  end

  def position
    8
  end
end
