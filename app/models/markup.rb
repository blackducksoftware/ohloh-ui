# frozen_string_literal: true

class Markup < ApplicationRecord
  before_save :sanitize_html
  after_save :notify_about_added_links

  validates :raw, length: { maximum: 500 }, allow_blank: true

  def lines
    formatted.to_s.split('<br/>')
  end

  def first_line
    lines.first.to_s.strip if formatted.present?
  end

  def link?
    formatted.match(/https?:\/\/[^\s]+/)
  end

  private

  def sanitize_html
    self.formatted = raw.strip_tags_preserve_line_breaks
  end

  def notify_about_added_links
    account = Account.find_by(about_markup_id: id)
    AccountMailer.review_account_data_for_spam(account).deliver_now if account && saved_change_to_formatted? && link?
  end
end
