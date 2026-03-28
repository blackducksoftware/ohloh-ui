# frozen_string_literal: true

require 'addressable/uri'

module LinksHelper
  def safe_slice_host(url, length = 33)
    # Unescape and force valid UTF-8 before sanitizing
    unescaped = CGI.unescape(url).encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    safe_url = ActionController::Base.helpers.sanitize(unescaped).to_s
    hostname = Addressable::URI.parse(safe_url).host
    truncate(hostname, length: length)
  end
end
