class Markup < ActiveRecord::Base
  before_save :sanitize_html

  private

  def sanitize_html
    self.formatted = raw.strip_tags_preserve_line_breaks
  end
end
