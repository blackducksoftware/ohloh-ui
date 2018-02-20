class FisbotApi
  API_URI = URI(ENV['FISBOT_API_URL']).freeze

  def fetch
    url = API_URI + "/api/v1/#{@endpoint}.json"
    url.query = URI.encode_www_form(params)
    Net::HTTP.get_response(url).body
  end

  def create
    url = API_URI + "/api/v1/#{@endpoint}.json"
    Net::HTTP.post_form(url, params)
  end

  def delete
    request = Net::HTTP::Delete.new(API_URI + "/api/v1/#{@endpoint}/delete.json")
    request.set_form_data(params)
    Net::HTTP.new(API_URI.host, API_URI.port).request(request)
  end

  def params
    { api_key: ENV['FISBOT_CLIENT_REGISTRATION_ID'] }.merge(@data)
  end
end
