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

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def sidebar
    [
      [
        [:account_summary,    h.t(:account_summary),      h.account_path(object)],
        [:stacks, object == h.current_user ? h.t(:my_stacks) : h.t(:stacks), h.account_stacks_path(object)],
        [:widgets,            'Widgets',              h.account_widgets_path(object)]
      ],
      [
        [:contributions,      h.t(:contributions),        nil],
        [:positions,          h.t(:contributions),        h.account_positions_path(object)],
        [:languages,          h.t(:languages),            h.languages_account_path(object)]
      ],
      [
        [:recognition,        h.t(:recognition),          nil],
        [:kudos,              h.t(:kudos),                h.account_kudos_path(object)]
      ],
      [
        [:usage,              h.t(:usage),                nil],
        [:edit_history,       h.t(:website_edits),        h.account_edits_path(object)],
        [:posts,              h.t(:post),                h.account_posts_path(object)],
        [:reviews,            h.t(:reviews),              h.account_reviews_path(object)]
      ]
    ].tap do |menus|
      append_project_menu(menus) if projects.exists?
      append_setting_menu(menus) if current_user_or_admin?
      append_report_menu(menus)
      append_unclaimed_contribution_menu(menus) if claim_core.unclaimed_persons_count > 0 && current_user_or_admin?
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  def append_project_menu(menus)
    menus.first << [:managed_projects, h.t(:managed_projects), h.account_projects_path(object)] if projects.exists?
  end

  def append_setting_menu(menus)
    menus.first.insert(1, [:settings, h.t(:settings), h.settings_account_path(object)]) if current_user_or_admin?
  end

  def append_unclaimed_contribution_menu(menus)
    menus.second << [:unclaimed, h.t(:claim_contributions), h.account_unclaimed_committers_path]
  end

  def append_report_menu(_menus)
    # TODO: account reports
    # if object.reports.exists? && object == h.current_user
    #   menus.first << [:reports, 'My Reports', account_reports_path(object)]
    # end
  end

  def current_user_or_admin?
    object.eql?(h.current_user) || h.current_user_is_admin?
  end
end
