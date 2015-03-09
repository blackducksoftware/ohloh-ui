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

  def analysis_total_lines(lbs)
    lbs.collect { |lb| analysis_calculate_sum_for(lb) }.sum
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

    lbs = Analysis.connection.select_all <<-SQL
      SELECT #{analysis_language_breakdown_select} FROM activity_facts AF
        INNER JOIN languages L ON AF.language_id = L.id
      WHERE AF.analysis_id = #{ analysis.id } AND AF.on_trunk
      GROUP BY L.id, L.nice_name, L.name, L.category
      ORDER BY SUM(AF.code_added - AF.code_removed) DESC, L.nice_name, L.name, L.category
    SQL

    lbs.select { |lb| lb['code'].to_i > 0 || lb['comments'].to_i > 0 }
  end

  def analysis_language_breakdown_select
    <<-SQL
      SUM(AF.code_added - AF.code_removed) AS code
      ,SUM(AF.comments_added - AF.comments_removed) AS comments
      ,SUM(AF.blanks_added - AF.blanks_removed) AS blanks
      ,L.id AS language_id
      ,L.nice_name AS language
      ,L.name AS language_name
      ,L.category
    SQL
  end
end
