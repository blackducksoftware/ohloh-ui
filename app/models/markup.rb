class Markup < ActiveRecord::Base
  before_save :sanitize_html

  validates :raw, length: { maximum: 500 }, allow_blank: true

  private

  def sanitize_html
    self.formatted = raw.strip_tags_preserve_line_breaks
  end
end
