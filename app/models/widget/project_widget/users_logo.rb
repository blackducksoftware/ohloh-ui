# frozen_string_literal: true

class ProjectWidget::UsersLogo < ProjectWidget
  def height
    40
  end

  def width
    150
  end

  def short_nice_name
    I18n.t('project_widgets.users_logo.short_nice_name')
  end

  def title
    I18n.t('project_widgets.users_logo.title')
  end

  def position
    11
  end
end
