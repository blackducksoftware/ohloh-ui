class Badge
  attr_reader :account, :vars

  def initialize(account, vars = {})
    @account = account
    @vars = vars
  end

  def self.ordered_badges
    [
      # DescriberBadge,
      # RepoPersonBadge,
      # ProjectManagerBadge,
      # StackerBadge,
      # OrgManagerBadge,
      # FOSSerBadge,
      # TaxonomistBadge,
      KudoRankBadge
    ]
  end

  def self.all_eligible(account)
    badges = self.ordered_badges.collect do |klass|
      badge = klass.new(account)
      badge if badge.eligible?
    end
    badges.compact.sort_by(&:position)
  end

  def eligible?
    eligibility_count > (level_limits.first || 1) - 1
  end

  def description(and_name = true)
    desc = has_levels? ? "Level #{level} " : ''
    if and_name
      desc << name
      desc << ": #{short_desc}" unless short_desc.empty?
    end
    desc.strip
  end

  def name
    self.class.to_s.sub(/Badge/, '').titleize
  end

  def short_desc
    fail "Not implemented"
  end

  def has_levels?
    level_limits.any?
  end

  def level_limits
    []
  end

  def level
    return 0 unless has_levels?
    count, lvl = eligibility_count, -1
    level_limits.each do |limit|
      lvl += 1
      return lvl if count < limit
    end
    lvl + 1
  end

  def level_bits
    level.to_s(2).rjust(4, '0')
  end

  def to_underscore
    self.class.name.gsub("Badge", "").underscore
  end

  def decorator
    @decorator ||= BadgesDecorator.new(self)
  end
end
