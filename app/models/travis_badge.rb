class TravisBadge < ProjectBadge
  def badge_image
    "https://api.travis-ci.org/#{url}"
  end
end
