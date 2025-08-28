# frozen_string_literal: true

# Monkey-patch for Ruby 3+: URI.escape has been removed, so we alias it to CGI.escape for legacy Paperclip or other gems
require 'cgi'
module URI
  def self.escape(str)
    CGI.escape(str.to_s)
  end
end
