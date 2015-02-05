class ProjectManagerBadge < Badge
  def eligibility_count
    @count ||= vars[:manages_project_count]
    @count ||=
      Project.joins(:manages)
      .where('NOT deleted AND approved_by IS NOT NULL AND account_id = #{account.id}')
      .count
  end

  def name
    'Big Cheese'
  end

  def short_desc
    'manages projects'
  end

  def position
    30
  end
end
