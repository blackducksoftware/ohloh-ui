# frozen_string_literal: true

class Codeopenhub
  def self.matches?(request)
    request.subdomain.include?(ENV.fetch('CODE_SUBDOMAIN', nil))
  end
end
