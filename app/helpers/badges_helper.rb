module BadgesHelper
  def image_url(badge)
    return nil unless Badge.descendants.include?(badge.class)
    url = BADGE_IMAGE_ROOT + badge.to_underscore + '.png'
    base_url + url if url
  end

  def pips_url(level)
    return nil unless (1..15).include?(level) # NOTE: Static number of PIP images
    file = BADGE_IMAGE_ROOT + sprintf("pips_%02i.png", level)
    base_url + file
  end

  private

  def base_url
    request.protocol + request.host_with_port
  end
end
