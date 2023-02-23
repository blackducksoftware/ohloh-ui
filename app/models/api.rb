# frozen_string_literal: true

class Api
  ALLOWED_RESPONSE_CODE = %w[200 300 301 404 410].freeze

  class << self
    def get_response(url)
      uri = URI(url)
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{get_jwt_token}"
      get_result(uri, request)
    end

    def get_jwt_token
      unless Rails.cache.read('api_jwt_token')
        uri = URI(ENV['KB_AUTH_API'])
        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = ENV['KB_API_AUTH_KEY']
        _code, response = get_result(uri, request)
        Rails.cache.write('api_jwt_token', response['jsonWebToken'], expires_in: response['expiresInMillis'] / 1000)
      end

      Rails.cache.read('api_jwt_token')
    end

    private

    def get_result(uri, request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request['Content-Type'] = 'application/json'
      request['User-Agent'] = 'ohloh-ui'
      response = http.request(request)
      [response.code, JSON.parse(response.body)]
    end
  end
end
