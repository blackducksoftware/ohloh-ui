require_relative 'api_access'

class FisbotApi
  attr_accessor :errors
  attr_reader :attributes

  def initialize(data = {})
    set_attributes(data)
    @errors = {}
  end

  def save
    uri = api_access.resource_uri
    response = Net::HTTP.post_form(uri, attributes)
    self.class.handle_errors(response) do
      hsh = JSON.parse(response.body)
      set_attributes_or_errors(response, hsh)
    end
  rescue JSON::ParserError
    response.body
  end

  def update(data)
    uri = api_access.resource_uri(@id)
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.send_request('PATCH', uri, data.to_query)
    hsh = JSON.parse(response.body)
    set_attributes_or_errors(response, hsh)
  end

  def valid?
    uri = api_access.resource_uri(:valid)
    response = Net::HTTP.post_form(uri, attributes)
    response.is_a?(Net::HTTPSuccess)
  end

  def fetch
    uri = api_access.resource_uri(nil, attributes)
    Net::HTTP.get_response(uri).body
  end

  def delete
    uri = api_access.resource_uri(attributes.values.join('/'))
    request = Net::HTTP::Delete.new(uri)
    response = Net::HTTP.new(uri.host, uri.port).request(request)
    self.class.handle_errors(response) { response }
  end

  def set_attributes(hsh)
    @attributes = hsh
    hsh.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  class << self
    def find(id)
      uri = api_access.resource_uri(id)
      response = Net::HTTP.get_response(uri)
      handle_errors(response) { new(JSON.parse(response.body)) }
    end

    def all(params)
      uri = api_access.resource_uri(nil, params)
      response = Net::HTTP.get_response(uri)
      handle_errors(response) { build_objects(response) }
    end

    def resource
      name.tableize
    end

    def create(hsh)
      object = new(hsh)
      object.save
      object
    end

    def handle_errors(response)
      case response
      when Net::HTTPServerError
        raise StandardError, "#{I18n.t('api_exception')} : #{response.message} => #{response.body}"
      else
        yield
      end
    end

    def api_access
      ApiAccess.new(resource)
    end

    def build_objects(response)
      return [] if response.is_a?(Net::HTTPNoContent)
      JSON.parse(response.body).map { |hsh| new(hsh) }
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

  def api_access
    self.class.api_access
  end
end
