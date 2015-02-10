class AccountDecorator < Cherry::Decorator
  delegate :best_vita, :positions, :claimed_positions, :projects, :markup, :twitter_account, to: :account

  def symbolized_commits_by_project
    best_vita.vita_fact.commits_by_project.to_a.map(&:symbolize_keys)
  end

  def symbolized_commits_by_language
    best_vita.vita_fact.commits_by_language.to_a.map(&:symbolize_keys)
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
    if claimed_positions.any? && best_vita.nil?
      I18n.t('accounts.show.analysis_scheduled')
    elsif positions.empty?
      I18n.t('accounts.show.no_contributions')
    elsif claimed_positions.blank?
      I18n.t('accounts.show.no_commits')
    end
  end

  # NOTE: Replaces twitter_card_description in accounts_helper
  def twitter_card
    return '' unless markup
    name_fact = best_vita.vita_fact
    content = markup.first_line.to_s
    return content if name_fact.nil?
    content + twitter_card_commits(name_fact) + addtional_twitter_descripion
  end

  def twitter_url(url)
    "https://twitter.com/intent/follow?original_referer=#{ CGI.escape(url) }&region=follow_link&"\
      "screen_name=#{ twitter_account }&source=followbutton&variant=2.0"
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def sidebar_for(current_user)
    [
      [
        [:account_summary,    I18n.t(:account_summary),      h.account_path(account)],
        [:stacks, account == current_user ? I18n.t(:my_stacks) : I18n.t(:stacks_title), h.account_stacks_path(account)],
        [:widgets,            'Widgets',              h.account_widgets_path(account)]
      ],
      [
        [:contributions,      I18n.t(:contributions),        nil],
        [:positions,          I18n.t(:contributions),        h.account_positions_path(account)],
        [:languages,          I18n.t(:languages),            h.languages_account_path(account)]
      ],
      [
        [:recognition,        I18n.t(:recognition),          nil],
        [:kudos,              I18n.t(:kudos),                h.account_kudos_path(account)]
      ],
      [
        [:usage,              I18n.t(:usage),                nil],
        [:edit_history,       I18n.t(:website_edits),        h.account_edits_path(account)],
        [:posts,              I18n.t(:post),                h.account_posts_path(account)],
        [:reviews,            I18n.t(:reviews),              h.account_reviews_path(account)]
      ]
    ].tap do |menus|
      append_project_menu(menus) if projects.exists?
      append_setting_menu(menus) if current_or_admin?(current_user)
      # TODO: account reports
      # append_report_menu(menus) if account == current_user && account.reports.exists?
      if account.claim_core.unclaimed_persons_count > 0 && current_or_admin?(current_user)
        append_unclaimed_contribution_menu(menus)
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  def twitter_card_commits(name_fact)
    commits_count = pluralize(name_fact.commits, I18n.t('accounts.show.total_commits'))
    positions_count = pluralize(positions.count, I18n.t('accounts.show.project'))
    I18n.t('accounts.show.commits_to', commits: commits_count, positions: positions_count)
  end

  # rubocop:disable UselessAssignment, Metrics/LineLength
  def addtional_twitter_descripion
    content = I18n.t('accounts.show.experience_in', nice_name: most_experienced_language.nice_name) if most_experienced_language
    content += I18n.t('accounts.show.earned') + badges.collect(&:name).to_sentence(last_word_connector: I18n.t('accounts.show.and'))
  end
  # rubocop:enable UselessAssignment, Metrics/LineLength

  def append_project_menu(menus)
    menus.first << [:managed_projects, I18n.t(:managed_projects), h.account_projects_path(account)]
  end

  def append_setting_menu(menus)
    menus.first.insert(1, [:settings, I18n.t(:settings), h.settings_account_path(account)])
  end

  def append_unclaimed_contribution_menu(menus)
    menus.second << [:unclaimed, I18n.t(:claim_contributions), h.account_unclaimed_committers_path]
  end

  def append_report_menu(menus)
    menus.first << [:reports, 'My Reports', account_reports_path(account)]
  end

  def current_or_admin?(current_user)
    account.eql?(current_user) || Account::Access.new(current_user).admin?
  end
end
