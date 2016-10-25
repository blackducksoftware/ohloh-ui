class CiiBadge < ProjectBadge
  validates :identifier, numericality: { only_integer: true }
  API_BASE_URL = I18n.t('.project_badges.cii_base_url').freeze

  def badge_url
    "#{API_BASE_URL}#{I18n.t('.project_badges.cii_mid_url')}#{identifier}#{I18n.t('.project_badges.cii_end_url')}"
  end

  def self.badge_name
    'Core Infrastructure Initiative'
  end
end
