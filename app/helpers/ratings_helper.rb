# frozen_string_literal: true

module RatingsHelper
  STAR_PATH = 'M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 ' \
              '1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034 ' \
              'a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 ' \
              '8.72c-.783-.57-.381-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z'

  def rating_stars(id, score)
    "<span id=\"#{id}\"> \
      #{rating_star_schema(score)} \
      #{svg_star_rating(score)} \
    </span>"
  end

  private

  def svg_star_rating(score)
    stars_html = (1..5).map do |star|
      star_filled = star <= score.to_f
      half_filled = !star_filled && (star - 0.5) <= score.to_f

      color = star_filled || half_filled ? '#ffb91a' : '#d1d5db'
      build_star_svg(color)
    end.join

    "<span style=\"display: flex; align-items: center; gap: 2px;\">#{stars_html}</span>"
  end

  def build_star_svg(color)
    '<svg style="width: 14px; height: 14px; display: inline; margin-right: 2px; ' \
      "color: #{color}; fill: currentColor;\" viewBox=\"0 0 20 20\"> " \
      "<path d=\"#{STAR_PATH}\"></path> </svg>"
  end

  def rating_star_schema(score)
    '<div style="display:none;" itemprop="aggregateRating" itemscope ' \
      'itemtype="http://schema.org/AggregateRating"> ' \
      "<span style=\"display:none;\" itemprop=\"ratingValue\">#{score}</span> </div>"
  end
end
