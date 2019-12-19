# frozen_string_literal: true

class AccountDecorator < Cherry::Decorator
  include ActionView::Helpers::TextHelper

  delegate :best_vita, :positions, :claimed_positions, :projects, to: :account

  def symbolized_commits_by_project
    NameFact.where(vita_id: best_vita.id).map(&:commits_by_project).flatten.compact.map(&:symbolize_keys)
  end

  def symbolized_commits_by_language
    NameFact.where(vita_id: best_vita.id).map(&:commits_by_language).flatten.compact.map(&:symbolize_keys)
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

  def vita_status_message
    if claimed_positions.any? && best_vita.nil?
      I18n.t('accounts.show.analysis_scheduled')
    elsif positions.empty?
      I18n.t('accounts.show.no_contributions')
    elsif claimed_positions.blank?
      I18n.t('accounts.show.no_commits')
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def sidebar_for(current_user)
    [
      [
        [:account_summary, I18n.t(:account_summary), h.account_path(account)],
        [:stacks, account == current_user ? I18n.t(:my_stacks) : I18n.t(:stacks_title), h.account_stacks_path(account)],
        [:widgets,            'Widgets', h.account_widgets_path(account)]
      ],
      [
        [:contributions,      I18n.t(:contribution),        nil],
        [:positions,          I18n.t(:contribution),        h.account_positions_path(account)],
        [:languages,          I18n.t(:languages_menu), h.account_languages_path(account)]
      ],
      [
        [:recognition,        I18n.t(:recognition),          nil],
        [:kudos,              I18n.t(:kudos_menu),           h.account_kudos_path(account)]
      ],
      [
        [:usage,              I18n.t(:usage),                nil],
        [:edit_history,       I18n.t(:website_edits),        h.account_edits_path(account)],
        [:posts,              I18n.t(:post),                 h.account_posts_path(account)],
        [:reviews,            I18n.t(:reviews_text),         h.account_reviews_path(account)]
      ]
    ].tap do |menus|
      append_project_menu(menus) if projects.exists?
      append_setting_menu(menus) if current_or_admin?(current_user)
      # TODO: account reports
      # append_report_menu(menus) if account == current_user && account.reports.exists?
      append_unclaimed_contribution_menu(menus, current_user) if !current_user.nil? && (account.id == current_user.id)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  def append_project_menu(menus)
    menus.first << [:managed_projects, I18n.t(:managed_projects), h.account_projects_path(account)]
  end

  def append_setting_menu(menus)
    menus.first.insert(1, [:settings, I18n.t(:settings), h.settings_account_path(account)])
  end

  def append_unclaimed_contribution_menu(menus, current_user)
    url_options = { query: current_user.claim_core.emails.join(' '), find_by: 'email', flow: 'account' }
    menus.second << [:unclaimed, I18n.t(:claim_contributions), h.committers_path(url_options)]
  end

  def current_or_admin?(current_user)
    account.eql?(current_user) || current_user.access.admin?
  end
end
