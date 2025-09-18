# frozen_string_literal: true

class Badge::KudoRankBadge < Badge
  def eligibility_count
    account.kudo_rank
  end

  def short_desc
    ''
  end

  def levels?
    true
  end

  def level
    account.kudo_rank
  end

  def position
    80
  end
end
