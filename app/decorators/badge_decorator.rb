class BadgeDecorator < Draper::Decorator
  delegate_all

  def image_url
    return nil unless Badge.descendants.include?(object.class)
    url = BADGE_IMAGE_ROOT + to_underscore + '.png'
    h.base_url + url if url
  end

  def pips_url
    return nil unless (1..15).include?(level)
    file = BADGE_IMAGE_ROOT + sprintf("pips_%02i.png", level)
    h.base_url + file
  end

  def css_class(size, header, index)
    is_last = index == size - 1
    is_last ||= header == :large && size > 4 && index == 3
    object.class.to_s.underscore.dasherize + (is_last ? ' last' : '')
  end
end
