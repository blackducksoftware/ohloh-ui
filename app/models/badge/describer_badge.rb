class DescriberBadge < Badge
  def eligibility_count
    @eligibility_count ||= vars[:desc_edit_count]
    @eligibility_count ||= Edit.where(target_type: 'Project', key: 'description', account_id: account.id).count
  end

  def short_desc
    I18n.t('badges.describer.short_desc')
  end

  def level_limits
    [1, 4, 10, 20, 50, 100, 200, 400, 600, 800]
  end

  def position
    10
  end
end
