# frozen_string_literal: true

class ScanCoverityApi
  URL = ENV['COVERITY_SCAN_URL']

  class << self
    def resource_uri(path = nil, _query = {})
      URI("#{URL}/#{path}.json")
    end

    def get_response(path = nil, query = {})
      uri = resource_uri(path, query)
      response = Net::HTTP.get_response(uri)
      handle_errors(response) { JSON.parse(response.body) }
    end

    def save(path = nil, query = {})
      uri = resource_uri(path, query)
      response = Net::HTTP.post_form(uri, query)
      handle_errors(response) do
        hsh = JSON.parse(response.body)
        set_attributes_or_errors(response, hsh)
      end
    rescue JSON::ParserError
      response.body
    end

    private

    def handle_errors(response)
      case response
      when Net::HTTPServerError
        raise ScanCoverityApiError, "#{response.message} => #{response.body}"
      else
        yield
      end
    end

    def save_success?(response)
      response.is_a?(Net::HTTPSuccess)
    end

    def set_errors(hsh)
      @errors = hsh.key?('error') ? hsh['error'].with_indifferent_access : hsh
      false
    end

    def set_attributes(hsh)
      @attributes = hsh
      hsh.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def set_attributes_or_errors(response, hsh)
      save_success?(response) ? set_attributes(hsh) : set_errors(hsh)
    end
  end
end
