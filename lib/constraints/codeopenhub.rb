# frozen_string_literal: true

class Codeopenhub
  def self.matches?(request)
    subdomain = ENV['CODE_SUBDOMAIN'] || ''
    return false if subdomain.empty?

    request.subdomain.include?(subdomain)
  end
end
