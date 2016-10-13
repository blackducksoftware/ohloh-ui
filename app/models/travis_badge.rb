class TravisBadge < ProjectBadge

  def self.badge_template
    "https://api.travis-ci.org/<input type='text' name='project_badge[url]' id='project_badge_url'>"
  end

  def badge_image
    "https://api.travis-ci.org/#{url}"
  end
end
