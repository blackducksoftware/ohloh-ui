# frozen_string_literal: true

class OrganizationWidget::AffiliatedCommittersActivity < OrganizationWidget
  def short_nice_name
    I18n.t('organization_widgets.affiliated_committers_activity.short_nice_name')
  end

  def title
    I18n.t('organization_widgets.affiliated_committers_activity.title')
  end

  def position
    3
  end
end
