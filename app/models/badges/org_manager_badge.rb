class OrgManagerBadge < Badge
  def eligibility_count
    @count ||= vars[:manages_org_count]
    @count ||=
      Organization.joins(:manages)
      .where("NOT deleted AND approved_by IS NOT NULL AND account_id = #{account.id}")
      .count
  end

  def name
    'Org Man'
  end

  def short_desc
    'manages organizations'
  end

  def position
    50
  end
end
