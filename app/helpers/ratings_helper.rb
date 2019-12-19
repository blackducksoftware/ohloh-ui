# frozen_string_literal: true

module RatingsHelper
  def rating_stars(id, score, mini = false)
    dim = rating_star_dimensions(mini)
    width = (score.to_f * (dim[:max] - dim[:min]) / 5.0 + 0.5 + dim[:min]).to_i
    rating_star_html(id, score, dim, width)
  end

  private

  def rating_star_html(id, score, dim, width)
    return rating_star_worst(id, score, dim) if width <= dim[:min]
    return rating_star_best(id, score, dim) if width >= dim[:max]

    rstarfull(id, score, "#{rating_star_row(dim, width, false)} #{rating_star_row(dim, dim[:max] - width, true)}")
  end

  def rating_star_worst(id, score, dim)
    rstarfull(id, score, rating_star_row(dim, dim[:max], true))
  end

  def rating_star_best(id, score, dim)
    rstarfull(id, score, rating_star_row(dim, dim[:max], false))
  end

  def rating_star_dimensions(mini)
    return { max: 76, min: 1, height: 17, img: 'stars_sprite_mini.png' } if mini

    { max: 112, min: 2, height: 23, img: 'stars_sprite.png' }
  end

  def rstarfull(id, score, ratings)
    "<span id=\"#{id}\"> \
      #{rating_star_schema(score)} #{ratings} \
    </span>"
  end

  def rating_star_schema(score)
    <<-HTML
    <div style = "display:none;" itemprop="aggregateRating" itemscope itemtype="http://schema.org/AggregateRating">
      <span style = "display:none;" itemprop="ratingValue">#{score}</span>
    </div>
    HTML
  end

  def rating_star_row(dimensions, width, empty)
    position = empty ? 'right top' : 'left bottom'
    "<span style=\"font-size: 1px; float: left; display: inline; height: #{dimensions[:height]}px; width: #{width}px; \
                   background: url(" + image_path("rating_stars/#{dimensions[:img]}") + ") #{position}\"> \
      &nbsp; \
    </span>"
  end
end
