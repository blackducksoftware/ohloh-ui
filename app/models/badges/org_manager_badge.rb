class OrgManagerBadge < Badge
  def eligibility_count
    @count ||= vars[:manages_org_count]
    @count ||= Organization.joins(:manages)
               .where{deleted.not_eq(true) & manages.approved_by.not_eq(nil) & manages.account_id.eq(my{account.id})}.count
  end

  def name
    "Org Man"
  end

  def short_desc
    "manages organizations"
  end

  def position
    50
  end
end
