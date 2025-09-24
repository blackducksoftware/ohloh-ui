# frozen_string_literal: true

require 'addressable/uri'
module LinksHelper
  def safe_slice_host(url, length = 33)
    safe_url = sanitize(CGI.unescape(url))
    hostname = Addressable::URI.parse(safe_url).host
    truncate(hostname, length: length)
  end
end
