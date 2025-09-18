# frozen_string_literal: true

module OpenhubSecurity
  def self.validate_response(json)
    json.dig('response', 'numFound') && json['response']['numFound'].to_i.positive?
  end

  def self.get_uuid(project_name)
    url = ENV.fetch('KB_PROJECT_SEARCH_URL', nil) + "&q=#{CGI.escape(project_name)}"
    json = get_response(url)
    json['response']['docs'][0]['uuid'] if validate_response(json)
  end

  def self.get_http(url)
    # Parse the URL to get the host and port and convert to a Net::HTTP object
    # With that object, we can set "use_ssl" explicitly
    parsed_url = URI.parse(url)
    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true
    http
  end

  def self.get_http_request(url)
    # Create a GET request so we can add the auth token to the header
    # We could combine lines:
    # "JSON.parse(http.request(request).read_body)", but this is easer to debug
    parsed_url = URI.parse(url)
    request = Net::HTTP::Get.new(parsed_url.request_uri)
    request['X-BDS-AuthToken'] = ENV.fetch('KB_AUTH_KEY', nil)
    request['User-Agent'] = "ohloh-ui/#{ENV.fetch('COMMIT_SHA', nil)}"
    request
  end

  def self.get_response(url)
    http = get_http(url)

    request = get_http_request(url)
    begin
      response = http.request(request)
      response = JSON.parse(response.read_body)
    rescue SocketError => e
      Rails.logger.error("OpenhubSecurity SocketError Exception:  #{e.message}")
    end
    response || {}
  end
end
