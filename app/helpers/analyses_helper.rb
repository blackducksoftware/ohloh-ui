module AnalysesHelper
  def analysis_ticker_markup(diff, previous)
    is_up = diff > 0
    haml_tag :span do
      concat t(is_up ? :up : :down)
      analysis_ticker_markup_percent(diff, previous, is_up)
      concat t(:from_prev_12_mo)
    end
  end

  def analysis_twelve_month_commits_ticker(analysis = nil)
    previous_summary = analysis.previous_twelve_month_summary
    return '' unless previous_summary && previous_summary.data?
    analysis_ticker_markup previous_summary.commits_difference, previous_summary.commits_count
  end

  def analysis_ticker_markup_percent(diff, previous, is_up)
    haml_tag :span, class: (is_up ? 'good' : 'bad') do
      concat "#{'+' if is_up}#{diff} "
      concat "(#{(diff.abs.to_f / previous.abs.to_f * 100).floor}%) " if previous > 0
    end
  end

  def analysis_language_percentages(analysis)
    return [] if analysis.empty?
    lbs = analysis_language_breakdown(analysis)
    language_infos(lbs, 100, analysis_total_lines(lbs))
  end

  def analysis_total_lines(lbs)
    lbs.collect { |lb| analysis_calculate_sum_for(lb) }.sum
  end

  def analysis_total_detail(analysis_language_breakdown, type)
   analysis_language_breakdown.collect { |line| line[type].to_i }.sum
  end

  def analysis_total_percent_detail(type, total_lines)
    number_with_precision(((type.to_i.to_f/total_lines.to_f) * 100), :precision => 1).to_s + "%"
  end

  def comments_ratio_from_lanaguage_breakdown(language_breakdown)
    comments_and_code_sum = language_breakdown.code_total + language_breakdown.comments_total
    comments_by_code = (language_breakdown.comments_total.to_f / comments_and_code_sum.to_f) * 100
    comments_and_code_sum > 0 ? number_with_precision(comments_by_code, precision: 1).to_s + '%' : '-'
  end

  def barfill_css(language_breakdown, lb)
    "width:#{total_percent(language_breakdown, lb).to_i}%;"\
    "background: ##{language_color(lb.language_name)}"
  end

  def total_percent(analysis_language_breakdown, lb)
    percentage = analysis_calculate_percentage lb, analysis_total_lines(analysis_language_breakdown)
    number_with_precision(percentage, precision: 1).to_s + '%'
  end

  private

  def language_infos(lbs, total_left, total_lines, result = [])
    lbs.each_with_index do |lb, index|
      percent = analysis_calculate_percentage(lb, total_lines)
      if analysis_remainder_langs?(percent, index, lbs.size)
        result << analysis_remainder_info(lbs, index, percent, total_left)
        break
      end
      total_left -= percent
      result << analysis_language_info(lb, (lb == lbs.last) ? total_left : percent)
    end
    result
  end

  def analysis_remainder_langs?(percent, index, total)
    (percent < 5 || index > 2) && index < (total - 1)
  end

  def analysis_remainder_info(lbs, index, percent, total_left)
    lbs_left = lbs[index..-1].collect do |lb_more|
      [lb_more['language_id'], lb_more['language'], { percent: percent }]
    end
    [nil, "#{lbs_left.size} Other", { percent: total_left, composed_of: lbs_left, color: '000000' }]
  end

  def analysis_language_info(lb, percent)
    [lb['language_id'], lb['language'],
     { url_name: lb['language_name'], percent: percent, color: language_color(lb['language_name']) }]
  end

  def analysis_calculate_sum_for(language_breakdown)
    language_breakdown['code'].to_i + language_breakdown['comments'].to_i + language_breakdown['blanks'].to_i
  end

  def analysis_calculate_percentage(language_breakdown, total_lines)
    return 0 if total_lines.to_i <= 0
    ((analysis_calculate_sum_for(language_breakdown) / total_lines.to_f) * 100).round
  end

  def analysis_language_breakdown(analysis)
    return [] if analysis.empty?
    analysis_language_breakdowns(analysis).select { |lb| lb['code'].to_i > 0 || lb['comments'].to_i > 0 }
  end

  def analysis_language_breakdowns(analysis)
    ActivityFact.select(analysis_language_breakdown_select)
      .joins(:language)
      .where(analysis_id: analysis.id, on_trunk: true)
      .group('languages.id, languages.nice_name, languages.name, languages.category')
      .order(analysis_language_breakdown_order).to_a
  end

  def analysis_language_breakdown_select
    <<-SQL
      SUM(activity_facts.code_added - activity_facts.code_removed) AS code
      ,SUM(activity_facts.comments_added - activity_facts.comments_removed) AS comments
      ,SUM(activity_facts.blanks_added - activity_facts.blanks_removed) AS blanks
      ,languages.id AS language_id
      ,languages.nice_name AS language
      ,languages.name AS language_name
      ,languages.category
    SQL
  end

  def analysis_language_breakdown_order
    <<-SQL
      SUM(activity_facts.code_added - activity_facts.code_removed) DESC,
      languages.nice_name, languages.name, languages.category
    SQL
  end
end
