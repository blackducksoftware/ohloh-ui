# frozen_string_literal: true

class TwitterDetail < Cherry::Decorator
  include ActionView::Helpers::TextHelper

  delegate :best_account_analysis, :positions, :markup, :twitter_account,
           :most_experienced_language, :badges, to: :account

  def description
    return '' unless markup

    name_fact = best_account_analysis.account_analysis_fact
    content = markup.first_line.to_s
    return content if name_fact.nil?

    content + commits_to(name_fact) + language_experience_text + badges_text
  end

  def url(request_url)
    "https://twitter.com/intent/follow?original_referer=#{CGI.escape(request_url)}&region=follow_link&"\
      "screen_name=#{twitter_account}&source=followbutton&variant=2.0"
  end

  private

  def commits_to(name_fact)
    commits_count = pluralize(name_fact.commits, I18n.t('accounts.show.total_commits'))
    positions_count = pluralize(positions.count, I18n.t('accounts.show.project'))
    I18n.t('accounts.show.commits_to', commits: commits_count, positions: positions_count)
  end

  def language_experience_text
    return '' unless most_experienced_language

    I18n.t('accounts.show.experience_in', nice_name: most_experienced_language.nice_name)
  end

  def badges_text
    I18n.t('accounts.show.earned') +
      badges.collect(&:name).to_sentence(last_word_connector: I18n.t('accounts.show.and'))
  end
end
