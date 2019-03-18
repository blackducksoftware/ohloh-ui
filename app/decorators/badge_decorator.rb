class BadgeDecorator < Cherry::Decorator
  delegate :to_underscore, :level, :level_bits, :levels?, :description, to: :object

  def image_url(request)
    url = BADGE_IMAGE_ROOT + to_underscore + '.png'
    base_url(request) + url if url
  end

  def pips_url(request)
    return nil unless (1..15).cover?(level)

    file = BADGE_IMAGE_ROOT + format('pips_%02i.png', level)
    base_url(request) + file
  end

  def css_class(size, header, index)
    is_last = index == size - 1
    is_last ||= header == :large && size > 4 && index == 3
    object.class.to_s.underscore.dasherize + (is_last ? ' last' : '')
  end

  private

  def base_url(request)
    request.protocol + request.host_with_port
  end
end
