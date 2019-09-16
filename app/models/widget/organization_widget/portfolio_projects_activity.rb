# frozen_string_literal: true

class OrganizationWidget::PortfolioProjectsActivity < OrganizationWidget
  def short_nice_name
    I18n.t('organization_widgets.portfolio_projects_activity.short_nice_name')
  end

  def title
    I18n.t('organization_widgets.portfolio_projects_activity.title')
  end

  def position
    2
  end
end
