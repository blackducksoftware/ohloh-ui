# frozen_string_literal: true

# rubocop: disable Lint/UriEscapeUnescape

module LinksHelper
  def safe_slice_host(url, length = 33)
    safe_url = sanitize(URI.encode(url))
    hostname = URI.parse(safe_url).host
    truncate(hostname, length: length)
  end
end
# rubocop: enable Lint/UriEscapeUnescape
