# frozen_string_literal: true

module AboutsHelper
  def compute_style_for_language_tag(language, sum)
    # Take the percentage of the sum of all language totals and then decrease by a factor of 8 rounding to 2 places
    em = sum.zero? ? 0.0 : ((language.total.fdiv(sum) * 100.0) / 8.0).round(2)
    weight = em >= 0.1 && em <= 1.1 ? 'bold' : 'normal'
    em = [em, 1.1].max
    em = [em, 3.5].min
    "font-size:#{em}em; font-weight:#{weight};"
  end
end
