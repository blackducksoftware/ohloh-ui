class AccountDecorator < Draper::Decorator
  delegate_all

  def symbolized_commits_by_project
    scbp = best_vita.try(:vita_fact).try(:commits_by_project)
    scbp.to_a.map(&:symbolize_keys)
  end

  def symbolized_commits_by_language
    scbp = best_vita.try(:vita_fact).try(:commits_by_language)
    scbp.to_a.map(&:symbolize_keys)
  end

  def sorted_commits_by_project
    cbp = symbolized_commits_by_project
    sorted_cbp = cbp.each_with_object({}) do |hsh, res|
      pos_id = hsh[:position_id].to_i
      res[pos_id] ||= 0
      res[pos_id] += hsh[:commits].to_i
    end
    sorted_cbp.sort_by { |_k, v| v }.reverse
  end

  def sorted_commits_by_language
    cbl = symbolized_commits_by_language
    sorted_cbl = cbl.each_with_object({}) do |hsh, res|
      lang = hsh[:l_name]
      res[lang] ||= { nice_name: hsh[:l_nice_name], commits: 0 }
      res[lang][:commits] += hsh[:commits].to_i
    end
    sorted_cbl.sort_by { |_k, v| v[:commits] }.reverse
  end
end
