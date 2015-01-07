class KudoRankBadge < Badge
  def eligibility_count
    account.kudo_rank
  end

  def short_desc
    ''
  end

  def has_levels?
    true
  end

  def level
    account.kudo_rank
  end

  def position
    80
  end
end
