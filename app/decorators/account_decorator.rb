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

  # NOTE: Replaces account_vita_status_message in application_helper
  def vita_status_message
    message =
    if has_claimed_positions? && best_vita.nil?
      'The analysis for this account has been scheduled.'
    elsif !has_claimed_positions? && has_positions?
      'There are no commits available to display.'
    elsif has_positions?
      'There are no contributions available to display.'
    end

    return message unless block_given?
    message.blank? ? yield : h.haml_tag(:p) { h.concat(message) }
  end

  # NOTE: Replaces twitter_card_description in application_helper
  def twitter_card
    name_fact = best_vita && best_vita.vita_fact
    content = ""
    if name_fact
      content += markup.first_line.concat(", ") if markup.first_line
      content += "#{pluralize(name_fact.commits, 'total commit')} to #{pluralize(positions.count, 'project')}".concat(", ")
      content += "most experienced in #{most_experienced_language.nice_name}".concat(", ") if most_experienced_language
      content += "earned " + badges.collect(&:name).to_sentence(:last_word_connector => " and ")
    elsif markup.first_line
      content = markup.first_line
    end
    content
  end
end
