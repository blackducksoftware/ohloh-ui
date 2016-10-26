class CiiBadge < ProjectBadge
  validates :identifier, numericality: { only_integer: true }

  def badge_url
    "#{ ENV['CII_API_BASE_URL'] }#{I18n.t('.project_badges.cii_mid_url')}#{identifier}#{I18n.t('.project_badges.cii_end_url')}"
  end

  def self.badge_name
    'Core Infrastructure Initiative'
  end
end
