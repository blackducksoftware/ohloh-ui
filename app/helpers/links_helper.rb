# frozen_string_literal: true

module LinksHelper
  def safe_slice_host(url, length = 33)
    safe_url = sanitize(url)
    hostname = URI.parse(safe_url).host
    truncate(hostname, length: length)
  end
end
