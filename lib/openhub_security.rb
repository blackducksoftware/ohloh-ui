module OpenhubSecurity
  def self.get_uuid(project_name)
    url = ENV['KB_PROJECT_SEARCH_URL'] + "&q=#{URI.escape(project_name)}"
    json = JSON.parse(open(url).read)
    return json['response']['docs'][0]['uuid'] if json['response']['numFound'].to_i > 0
  end
end
