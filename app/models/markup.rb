# frozen_string_literal: true

class Markup < ActiveRecord::Base
  before_save :sanitize_html

  validates :raw, length: { maximum: 500 }, allow_blank: true

  def lines
    formatted.to_s.split('<br/>')
  end

  def first_line
    lines.first.to_s.strip if formatted.present?
  end

  private

  def sanitize_html
    self.formatted = raw.strip_tags_preserve_line_breaks
  end
end
