class String
  def strip_tags
    gsub(/<.*?>/, '')
  end

  def strip_tags_preserve_line_breaks
    html = CGI.unescapeHTML(self).delete("\r")

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

  def escape_single_quote
    gsub("'", "\\\\'")
  end

  def valid_http_url?
    URI.parse(self).is_a?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end

  def fix_encoding_if_invalid!
    force_encoding('utf-8').scrub!
  end

  def to_bool
    self =~ /^(true|t|yes|y|1)$/i ? true : false
  end

  def escape
    ActionController::Base.helpers.escape self
  end

  def escape_unclosed_tags
    ActionController::Base.helpers.escape_unclosed_tags self
  end

  def escape_invalid_tags
    ActionController::Base.helpers.escape_invalid_tags self
  end

  class << self
    def clean_string(str)
      return str if str.blank?
      str.to_s.strip.strip_tags
    end

    def clean_url(url)
      return url if url.blank?
      url.strip!
      url =~ %r{^(http:/)|(https:/)|(ftp:/)} ? url : "http://#{url}"
    end
  end
end
