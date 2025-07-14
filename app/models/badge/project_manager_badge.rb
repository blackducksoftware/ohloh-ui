# frozen_string_literal: true

class Badge::ProjectManagerBadge < Badge
  def eligibility_count
    @eligibility_count ||= vars[:manages_project_count]
    @eligibility_count ||= Project.managed_by(account).count
  end

  def name
    'Big Cheese'
  end

  def short_desc
    I18n.t('badges.project_manager.short_desc')
  end

  def position
    30
  end
end
