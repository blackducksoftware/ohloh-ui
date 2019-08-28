# frozen_string_literal: true

module OpenhubSecurity
  def self.get_uuid(project_name)
    url = ENV['KB_PROJECT_SEARCH_URL'] + "&q=#{CGI.escape(project_name)}"
    json = get_response(url)
    return json['response']['docs'][0]['uuid'] if json['response']['numFound'].to_i.positive?
  end

  def self.get_response(url)
    JSON.parse(URI.parse(url).open.read)
  end
end
