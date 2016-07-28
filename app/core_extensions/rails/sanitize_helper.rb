module ActionView::Helpers::SanitizeHelper
  def escape(html)
    escape_invalid_tags escape_unclosed_tags(html)
  end

  def escape_unclosed_tags(html)
    while (fixed_html = html.gsub(/<([^<>]*)(<|$)/, '&lt;\\1\\2')) && fixed_html != html
      html = fixed_html
    end
    fixed_html
  end

  def escape_invalid_tags(html)
    invalid_tags = html.scan(/<([^<>]*)>/).uniq.map do |tag|
      tag[0] if ActionView::Base.sanitized_allowed_tags.exclude?(tag[0].gsub(/(\/)|(\s.*)/, '').downcase)
    end.compact
    invalid_tags.map(&:escape_special_characters).each { |tag| html.gsub!(/<(#{tag}[^<>]*)>/, '&lt;\\1&gt;') }
    html
  end
end
