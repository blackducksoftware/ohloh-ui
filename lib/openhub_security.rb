# frozen_string_literal: true

module OpenhubSecurity
  def self.get_uuid(project_name)
    url = ENV['KB_PROJECT_SEARCH_URL'] + "&q=#{CGI.escape(project_name)}"
    json = get_response(url)
    return json['response']['docs'][0]['uuid'] if json&.dig('response', 'numFound') && json['response']['numFound'].to_i.positive?
  end

  def self.get_response(url)
    # Parse the URL to get the host and port and convert to a Net::HTTP object
    # With that object, we can set "use_ssl" explicitly
    parsed_url = URI.parse(url)
    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true

    # Create a GET request so we can add the auth token to the header
    # We could combine lines:
    # "JSON.parse(http.request(request).read_body)", but this is easer to debug
    request = Net::HTTP::Get.new(parsed_url.request_uri)
    request['X-BDS-AuthToken'] = ENV['KB_AUTH_KEY']
    request['User-Agent'] = "ohloh-ui/#{ENV['COMMIT_SHA']}"
    begin
      response = http.request(request)
      JSON.parse(response.read_body)
    rescue SocketError => e
      Rails.logger.error("SocketError Exception: #{parsed_url}")
      return nil
    end
  end
end
