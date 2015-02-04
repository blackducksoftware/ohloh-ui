class StackerBadge < Badge
  def eligibility_count
    @count ||= vars[:stacks_count]
    @count ||= Stack.where { project_count.gt(0) & deleted_at.eq(nil) & account_id.eq(my { account.id }) }.count
  end

  def short_desc
    'stacks projects'
  end

  def level_limits
    [1, 2, 3, 4, 5]
  end

  def position
    40
  end
end
