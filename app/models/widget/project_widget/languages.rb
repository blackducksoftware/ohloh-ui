# frozen_string_literal: true

class Widget::ProjectWidget::Languages < Widget::ProjectWidget
  def title
    I18n.t('project_widgets.languages.title')
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
