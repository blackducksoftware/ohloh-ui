module AnalysesHelper
  def analysis_total_lines(lbs)
    lbs.collect { |lb| analysis_calculate_sum_for(lb) }.sum
  end

  def analysis_total_detail(analysis_language_breakdown, type)
    analysis_language_breakdown.collect { |line| line[type].to_i }.sum
  end

  def analysis_total_percent_detail(type, total_lines)
    number_with_precision(((type.to_i.to_f / total_lines.to_f) * 100), precision: 1).to_s + '%'
  end

  def comments_ratio_from_lanaguage_breakdown(language_breakdown)
    comments_and_code_sum = language_breakdown.code_total + language_breakdown.comments_total
    comments_by_code = (language_breakdown.comments_total.to_f / comments_and_code_sum.to_f) * 100
    comments_and_code_sum > 0 ? number_with_precision(comments_by_code, precision: 1).to_s + '%' : '-'
  end

  def barfill_css(languages_breakdown, language_breakdown)
    "width:#{total_percent(languages_breakdown, language_breakdown).to_i}%;"\
    "background-color: ##{language_color(language_breakdown.language_name)}"
  end

  def total_percent(languages_breakdown, language_breakdown)
    percentage = analysis_calculate_percentage language_breakdown, analysis_total_lines(languages_breakdown)
    number_with_precision(percentage, precision: 1).to_s + '%'
  end

  private

  def analysis_calculate_sum_for(language_breakdown)
    language_breakdown.code_total + language_breakdown.comments_total + language_breakdown.blanks_total
  end

  def analysis_calculate_percentage(language_breakdown, total_lines)
    return 0 if total_lines.to_i <= 0

    ((analysis_calculate_sum_for(language_breakdown) / total_lines.to_f) * 100)
  end
end
