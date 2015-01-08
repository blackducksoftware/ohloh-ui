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
    sorted_cbp = cbp.inject({}) do |res, hsh|
      pos_id = hsh[:position_id].to_i
      res[pos_id] ||= 0
      res[pos_id] += hsh[:commits].to_i
      res
    end.sort_by { |k, v| v }.reverse
  end

  def sorted_commits_by_language
    cbl = symbolized_commits_by_language
    sorted_cbl = cbl.inject({}) do |res, hsh|
      lang = hsh[:l_name]
      res[lang] ||= { :nice_name => hsh[:l_nice_name], :commits => 0 }
      res[lang][:commits] += hsh[:commits].to_i
      res
    end.sort_by { |k, v| v[:commits] }.reverse
  end
end
