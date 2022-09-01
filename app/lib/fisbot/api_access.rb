# frozen_string_literal: true

require 'resolv'

class ApiAccess
  cattr_accessor :fis_ip_url

  URL = ENV['FISBOT_API_URL']
  KEY = ENV['FISBOT_CLIENT_REGISTRATION_ID']

  def initialize(resource)
    @resource = resource
  end

  def resource_uri(path = nil, query = {})
    path = "/#{path}" if path
    query[:api_key] = KEY
    URI("#{ApiAccess.api_url}/#{@resource}#{path}.json?#{query.to_query}")
  end

  class << self
    def api_url
      "#{fisbot_resolved_url}/api/v1"
    end

    def fis_public_url
      ENV['FISBOT_PUBLIC_URL'].presence || ENV['FISBOT_API_URL']
    end

    private

    def fisbot_resolved_url
      return URL if Rails.env.development? || Rails.env.test?
      return fis_ip_url if fis_ip_url && fis_ip_accessible?

      fis_ip_addr = resolve_hostname(URL)
      self.fis_ip_url = "http://#{fis_ip_addr}"
    end

    def fis_ip_accessible?
      uri = URI(fis_ip_url)
      response = Net::HTTP.get_response(uri)
      response.code == '200'
    end

    def resolve_hostname(url)
      hostname = url.sub(%r{https?://}, '').sub(/\/$/, '')
      Resolv.getaddress hostname
    end
  end
end
