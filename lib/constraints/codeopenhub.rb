class Codeopenhub
  def self.matches?(request)
    request.subdomain.include?(ENV['CODE_SUBDOMAIN'])
  end
end
