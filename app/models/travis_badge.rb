# frozen_string_literal: true

class TravisBadge < ProjectBadge
  def badge_url
    "#{ENV['TRAVIS_API_BASE_URL']}#{identifier}"
  end

  def self.badge_name
    'Travis CI'
  end
end
