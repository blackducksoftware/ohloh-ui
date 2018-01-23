class CodeLocationSubscription
  def initialize(code_location_id)
    @uri = URI(ENV['FISBOT_API_URL'])
    @params = { api_key: ENV['FISBOT_CLIENT_REGISTRATION_ID'], code_location_id: code_location_id }
  end

  def create
    url = @uri + '/api/v1/subscriptions.json'
    Net::HTTP.post_form(url, @params)
  end

  def delete
    request = Net::HTTP::Delete.new(@uri + '/api/v1/subscriptions/delete.json')
    request.set_form_data(@params)
    Net::HTTP.new(@uri.host, @uri.port).request(request)
  end
end
