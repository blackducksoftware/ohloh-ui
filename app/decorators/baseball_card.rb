# frozen_string_literal: true

class BaseballCard < Cherry::Decorator
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  ROW_NAMES = %i[first_checkin last_checkin commits joined_at contributions orgs
                 affiliations].freeze

  delegate :best_account_analysis, :created_at, :positions, to: :account

  def rows
    ROW_NAMES.map { |row| send(row) }.compact.map { |row| row.reverse_merge(css: {}) }
  end

  private

  def organization_core
    Account::OrganizationCore.new(account.id)
  end

  def account_analysis_fact
    account.best_account_analysis.account_analysis_fact
  end

  def first_checkin
    return unless account_analysis_fact.first_checkin

    { label: i18n('first_checkin'),
      value: i18n('duration', date: distance_of_time_in_words_to_now(account_analysis_fact.first_checkin)) }
  end

  def last_checkin
    return unless account_analysis_fact.last_checkin

    { label: i18n('last_checkin'),
      value: i18n('duration', date: distance_of_time_in_words_to_now(account_analysis_fact.last_checkin)) }
  end

  def commits
    return if best_account_analysis.nil?

    { label: i18n('commits.label'),
      value: i18n('commits.value', count: account_analysis_fact.commits) }
  end

  def joined_at
    { label: i18n('joined_at'),
      value: i18n('duration', date: distance_of_time_in_words_to_now(created_at)) }
  end

  def contributions
    return if positions.active.empty?

    link = link_to pluralize(positions.active.size, 'project'), h.account_positions_path(account)
    { label: i18n('contribution'),
      value: link }
  end

  def orgs
    orgs_for_positions = organization_core.orgs_for_my_positions
    return if orgs_for_positions.empty?

    { css: { style: 'min-height:38px;' },
      label: i18n('contributed_to'),
      partial: 'accounts/show/orgs',
      locals: { orgs: orgs_for_positions } }
  end

  def affiliations
    affiliated_orgs = organization_core.affiliations_for_my_positions
    return if affiliated_orgs.empty?

    { css: { style: 'min-height:38px;' },
      label: i18n('contributed_for'),
      partial: 'accounts/show/orgs',
      locals: { orgs: affiliated_orgs } }
  end

  def i18n(string, options = {})
    I18n.t("accounts.show.baseball_card.#{string}", options)
  end
end
