class TravisBadge < ProjectBadge
  def badge_image
    "https://api.travis-ci.org/#{url}"
  end

  def self.badge_name
    'Travis CI'
  end
end
