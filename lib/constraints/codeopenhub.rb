class Codeopenhub
  def self.matches?(request)
    request.subdomain.include?('code')
  end
end
