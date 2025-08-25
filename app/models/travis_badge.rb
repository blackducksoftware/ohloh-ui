# frozen_string_literal: true

class TravisBadge < ProjectBadge
  def badge_url
    "#{ENV.fetch('TRAVIS_API_BASE_URL', nil)}#{identifier}"
  end

  def self.badge_name
    'Travis CI'
  end
end
