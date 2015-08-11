module TwitterDigits
  module_function

  def get_twitter_id(service_provider_url, credentials)
    uri = URI(service_provider_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    data = { 'Authorization' => credentials }
    response = http.get2(uri.path, data)

    JSON.parse(response.body)['id_str'] if response.code == '200'
  end
end
