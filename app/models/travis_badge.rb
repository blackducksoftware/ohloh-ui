class TravisBadge < ProjectBadge
  API_BASE_URL = 'https://api.travis-ci.org'.freeze

  def badge_image
    "#{API_BASE_URL}/#{identifier}"
  end

  def self.badge_name
    'Travis CI'
  end
end
