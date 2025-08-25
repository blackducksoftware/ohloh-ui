# frozen_string_literal: true

class Badge::OrgManagerBadge < Badge
  def eligibility_count
    @eligibility_count ||= vars[:manages_org_count]
    @eligibility_count ||= Organization.managed_by(account).count
  end

  def name
    'Org Man'
  end

  def short_desc
    I18n.t('badges.org_manager.short_desc')
  end

  def position
    50
  end
end
