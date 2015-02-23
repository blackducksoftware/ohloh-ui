class ProjectManagerBadge < Badge
  def eligibility_count
    @count ||= vars[:manages_project_count]
    @count ||= Project.managed_by(account).count
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
