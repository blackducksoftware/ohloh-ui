class TravisBadge < ProjectBadge
  API_BASE_URL = I18n.t('.project_badges.travis_base_url').freeze

  def badge_url
    "#{API_BASE_URL}#{identifier}"
  end

  def self.badge_name
    'Travis CI'
  end
end
