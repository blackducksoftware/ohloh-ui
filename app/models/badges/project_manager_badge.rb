class ProjectManagerBadge < Badge
  def eligibility_count
    @count ||= vars[:manages_project_count]
    @count ||= Project.joins(:manages)
              .where do
                deleted.not_eq(true) & manages.approved_by.not_eq(nil) & manages.account_id.eq(my { account.id })
              end
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
