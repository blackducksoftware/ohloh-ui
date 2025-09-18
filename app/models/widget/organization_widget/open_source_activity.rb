# frozen_string_literal: true

class Widget::OrganizationWidget::OpenSourceActivity < Widget::OrganizationWidget
  def short_nice_name
    I18n.t('organization_widgets.open_source_activity.short_nice_name')
  end

  def position
    1
  end
end
