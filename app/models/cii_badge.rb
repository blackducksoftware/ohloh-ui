class CiiBadge < ProjectBadge
  validates :url, numericality: { only_integer: true }

  def self.badge_template
    "https://bestpractices.coreinfrastructure.org/projects/<input type='text' name='project_badge[url]' id='project_badge_url'>/badge"
  end

  def badge_image
    "https://bestpractices.coreinfrastructure.org/projects/#{url}/badge"
  end
end
