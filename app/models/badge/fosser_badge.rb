# frozen_string_literal: true

class FOSSerBadge < Badge
  def eligibility_count
    @eligibility_count ||= vars[:positions_count]
    @eligibility_count ||= Position.where(account_id: account.id).count
  end

  def name
    'FLOSSer'
  end

  def to_underscore
    'fosser'
  end

  def short_desc
    I18n.t('badges.fosser.short_desc')
  end

  def level_limits
    [1, 3, 6, 10, 20, 50, 100, 200]
  end

  def position
    60
  end
end
