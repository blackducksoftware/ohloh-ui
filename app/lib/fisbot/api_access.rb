# frozen_string_literal: true

require 'resolv'

class ApiAccess
  cattr_accessor :fis_ip_url, :uptime_verified_time

  URL = ENV.fetch('FISBOT_API_URL', nil)
  KEY = ENV.fetch('FISBOT_CLIENT_REGISTRATION_ID', nil)
  CACHE_DURATION = ENV.fetch('FISBOT_API_VERIFY_CACHE_MINS', 5).to_i.minutes

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
      ENV.fetch('FISBOT_PUBLIC_URL', nil).presence || ENV.fetch('FISBOT_API_URL', nil)
    end

    def available?
      return true unless uptime_check_expired?

      uri = URI("#{fisbot_resolved_url}/health")
      response = Net::HTTP.get_response(uri)
      response.code == '200' && set_uptime_verified_time
    rescue Errno::ECONNREFUSED, Resolv::ResolvError
      DataDogReport.error("Fisbot API outage: #{Time.now.utc}")
      false
    end

    private

    def set_uptime_verified_time
      self.uptime_verified_time = Time.current
    end

    def fisbot_resolved_url
      return URL if Rails.env.development? || Rails.env.test?

      reset_cache_data if uptime_check_expired?
      fis_ip_url || set_fis_ip_url
    end

    def reset_cache_data
      self.uptime_verified_time = nil
      self.fis_ip_url = nil
    end

    def uptime_check_expired?
      return true unless uptime_verified_time

      Time.current - uptime_verified_time > CACHE_DURATION
    end

    def set_fis_ip_url
      fis_ip_addr = resolve_hostname(URL)
      self.fis_ip_url = "http://#{fis_ip_addr}"
    end

    def resolve_hostname(url)
      hostname = url.sub(%r{https?://}, '').sub(/\/$/, '')
      Resolv.getaddress hostname
    end
  end
end
