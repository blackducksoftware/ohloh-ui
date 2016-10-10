class CiiBadge < ProjectBadge
  validates :url, numericality: { only_integer: true }

  def badge_image
    "https://bestpractices.coreinfrastructure.org/projects/#{url}/badge"
  end

  def self.badge_name
    'Core Infrastructure Initiative'
  end
end
