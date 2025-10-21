# frozen_string_literal: true

class OhlohAnalyticsApi
  URL = ENV.fetch('OHLOH_ANALYTICS_API_URL', nil)
  KEY = ENV.fetch('OHLOH_ANALYTICS_CLIENT_REGISTRATION_ID', nil)

  class << self
    def resource_uri(path = nil, query = {})
      query[:api_key] = KEY
      URI("#{URL}/#{path}.json?#{query.to_query}")
    end

    def get_response(path = nil, query = {})
      uri = resource_uri(path, query)
      response = Net::HTTP.get_response(uri)
      handle_errors(response) { JSON.parse(response.body) }
    end

    def job_url(job_id)
      "#{URL}/admin/jobs/#{job_id}"
    end

    private

    def handle_errors(response)
      case response
      when Net::HTTPServerError
        raise OhlohAnalyticsError, "#{response.message} => #{response.body}"
      else
        yield
      end
    end
  end
end
