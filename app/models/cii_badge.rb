class CiiBadge < ProjectBadge
  validates :identifier, numericality: { only_integer: true }
  API_BASE_URL = 'https://bestpractices.coreinfrastructure.org'.freeze

  def badge_image
    "#{API_BASE_URL}/projects/#{identifier}/badge"
  end

  def self.badge_name
    'Core Infrastructure Initiative'
  end
end
