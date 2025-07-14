# frozen_string_literal: true

class CiiBadge < ProjectBadge
  validates :identifier, numericality: { only_integer: true }

  def badge_url
    "#{ENV.fetch('CII_API_BASE_URL', nil)}projects/
    #{identifier}/badge"
  end

  def self.badge_name
    'Core Infrastructure Initiative'
  end
end
