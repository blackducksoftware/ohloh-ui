module StarHelper
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def stars(score, small_size: false)
    max, min, height, image_src = small_size ? [76, 1, 17, 'stars_sprite_mini.png'] : [112, 2, 23, 'stars_sprite.png']
    right_top_position, left_bottom_position = 'right top', 'left bottom'

    width = ((score || 0) * (max - min) / 5.0 + 0.5 + min).to_i

    if width < min
      star_tag(height, max, image_src, right_top_position)
    elsif width > max
      star_tag(height, max, image_src, left_bottom_position)
    else
      star_tag(height, width, image_src, left_bottom_position)
      star_tag(height, max - width, image_src, right_top_position)
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def star_tag(height, width, image_src, position)
    haml_tag :span, style: "font-size:1px;float:left;display:inline;height:#{height}px;width:#{width}px;" \
      "background:url(/assets/stars/#{image_src}) #{position}"
  end
end
