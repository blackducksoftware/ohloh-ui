# frozen_string_literal: true

class CiiBadge < ProjectBadge
  validates :identifier, numericality: { only_integer: true }

  def badge_url
    "#{ENV['CII_API_BASE_URL']}projects/
    #{identifier}/badge"
  end

  def self.badge_name
    'Core Infrastructure Initiative'
  end
end
