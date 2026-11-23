# frozen_string_literal: true

module RatingsHelper
  STAR_PATH = 'M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 ' \
              '1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034 ' \
              'a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 ' \
              '8.72c-.783-.57-.381-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z'

  def rating_stars(id, score, mini: false)
    "<span id=\"#{id}\"> \
      #{rating_star_schema(score)} \
      #{svg_star_rating(score, mini: mini)} \
    </span>"
  end

  private

  def svg_star_rating(score, mini: false)
    stars_html = (1..5).map { |star| build_star_for_rating(star, score, mini) }.join
    "<span style=\"display: flex; align-items: center; gap: 2px;\">#{stars_html}</span>"
  end

  def build_star_for_rating(star, score, mini)
    if star <= score.to_f
      build_star_svg('#ffb91a', mini: mini)
    elsif (star - 0.5) <= score.to_f
      build_half_star_svg(mini: mini)
    else
      build_star_svg('#d1d5db', mini: mini)
    end
  end

  def build_star_svg(color, mini: false)
    size = mini ? '12px' : '14px'
    %(<svg style="width: #{size}; height: #{size}; display: inline; margin-right: 2px; fill: #{color};" ) +
      %(viewBox="0 0 20 20"> <path d="#{STAR_PATH}"></path> </svg>)
  end

  def build_half_star_svg(mini: false)
    size = mini ? '12px' : '14px'
    gradient_id = "half-star-#{SecureRandom.hex(4)}"
    "<svg style=\"width: #{size}; height: #{size}; display: inline; margin-right: 2px;\" " \
      "viewBox=\"0 0 20 20\"> <defs> <linearGradient id=\"#{gradient_id}\"> " \
      '<stop offset="50%" stop-color="#ffb91a"/> ' \
      '<stop offset="50%" stop-color="#d1d5db"/> </linearGradient> </defs> ' \
      "<path d=\"#{STAR_PATH}\" fill=\"url(##{gradient_id})\"></path> </svg>"
  end

  def rating_star_schema(score)
    '<div style="display:none;" itemprop="aggregateRating" itemscope ' \
      'itemtype="http://schema.org/AggregateRating"> ' \
      "<span style=\"display:none;\" itemprop=\"ratingValue\">#{score}</span> </div>"
  end
end
