class FisbotApi
  API_URI = URI(ENV['FISBOT_API_URL']).freeze
  API_KEY = ENV['FISBOT_CLIENT_REGISTRATION_ID']

  attr_accessor :errors
  attr_reader :attributes

  def initialize(data = {})
    set_attributes(data)
    @errors = {}
  end

  def save
    uri = URI("#{API_URI}/api/v1/#{endpoint}.json")
    response = Net::HTTP.post_form(uri, params)
    hsh = JSON.parse(response.body)

    set_attributes_or_errors(response, hsh)
  rescue JSON::ParserError
    response.body
  end

  def update(hsh)
    data = { api_key: API_KEY }.merge(hsh)
    uri = URI("#{API_URI}/api/v1/#{endpoint}/#{@id}.json")
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.send_request('PATCH', uri.path, data.to_query)
    hsh = JSON.parse(response.body)
    set_attributes_or_errors(response, hsh)
  end

  def valid?
    uri = URI("#{API_URI}/api/v1/#{endpoint}/valid.json")
    response = Net::HTTP.post_form(uri, params)
    response.is_a?(Net::HTTPSuccess)
  end

  def fetch
    uri = URI("#{API_URI}/api/v1/#{endpoint}.json")
    uri.query = URI.encode_www_form(params)
    Net::HTTP.get_response(uri).body
  end

  def delete
    request = Net::HTTP::Delete.new(URI("#{API_URI}/api/v1/#{endpoint}/delete.json"))
    request.set_form_data(params)
    Net::HTTP.new(API_URI.host, API_URI.port).request(request)
  end

  def params
    { api_key: API_KEY }.merge(attributes)
  end

  def endpoint
    self.class.endpoint
  end

  def set_attributes(hsh)
    @attributes = hsh
    hsh.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  class << self
    def find(id)
      uri = URI("#{API_URI}/api/v1/#{endpoint}/#{id}.json?api_key=#{API_KEY}")
      response = Net::HTTP.get_response(uri)
      handle_errors(response) { new(JSON.parse(response.body)) }
    end

    def find_by(data)
      params = data.merge(api_key: API_KEY)
      uri = URI("#{API_URI}/api/v1/#{endpoint}/find_by.json")
      uri.query = params.to_query
      response = Net::HTTP.get_response(uri)
      handle_errors(response) { new(JSON.parse(response.body)) }
    end

    def endpoint
      name.tableize
    end

    def create(hsh)
      object = new(hsh)
      object.save
      object
    end

    def handle_errors(response)
      case response
      when Net::HTTPSuccess
        yield
      when Net::HTTPServerError
        raise StandardError, "#{I18n.t('api_exception')} : #{response.message}"
      end
    end
  end

  private

  def save_success?(response)
    response.is_a?(Net::HTTPSuccess)
  end

  def set_errors(hsh)
    @errors = hsh.key?('error') ? hsh['error'].with_indifferent_access : hsh
    false
  end

  def set_attributes_or_errors(response, hsh)
    if save_success?(response)
      set_attributes(hsh)
    else
      set_errors(hsh)
    end
  end
end
