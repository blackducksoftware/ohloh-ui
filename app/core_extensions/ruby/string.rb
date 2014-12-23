class String
  def strip_tags
    gsub(/<.*?>/, '')
  end

  def strip_tags_preserve_line_breaks
    html = CGI.unescapeHTML(self).gsub(/\r/, '')

    # Preserve line-breaking tags by converting them to carriage returns
    html.gsub!(/<br\s*\/?>\s*\n?/, "\n")
    html.gsub!(/<\/p>\s*\n?/, "\n\n")
    html.gsub!(/<p\s*\/>\s*\n?/, "\n\n")

    text = html.strip_tags

    # Restore line-breaking tags
    text.gsub!(/\n(\s*\n)+/, '<br/><br/>')
    text.gsub!(/\n/, '<br/>')

    # Strip leading and trailing breaks
    text.gsub!(/^(<br\/>)+/, '')
    text.gsub!(/(<br\/>)+$/, '')

    text
  end

  def from_postgres_array
    string_without_curlies = gsub(/(^{|}$)/, '')
    string_without_curlies_and_null = string_without_curlies.gsub(/NULL/, '')
    string_without_curlies_and_null.split(',').map(&:to_i)
  end
end
