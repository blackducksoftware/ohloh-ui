# frozen_string_literal: true

class Forge::Match
  require 'open-uri'
  require 'json'

  MAX_FORGE_COMM_TIME = 10

  attr_accessor :forge, :owner_at_forge, :name_at_forge

  def initialize(forge, owner_at_forge, name_at_forge)
    @forge = forge
    @owner_at_forge = owner_at_forge
    @name_at_forge = name_at_forge
  end

  def forge_id
    forge&.id
  end

  def get_json_api
    json_api_uri = URI(forge.json_api_url(self))
    return {} unless json_api_uri

    request = Net::HTTP::Get.new(json_api_uri)
    if ENV['GITHUB_AUTH_TOKEN'] && json_api_uri.host == 'api.github.com'
      request['Authorization'] = "token #{ENV['GITHUB_AUTH_TOKEN']}"
    end
    get_result(json_api_uri, request)
  end

  def project
    Project.new(forge.get_project_attributes(self).merge(code_location_object: code_locations.first))
  end

  def code_locations
    forge.get_code_location_attributes(self).map do |hsh|
      next unless hsh[:scm_type]

      CodeLocation.new(hsh)
    end.uniq
  end

  def to_s
    owner_at_forge ? "#{forge.name}:#{owner_at_forge}/#{name_at_forge}" : "#{forge.name}:#{name_at_forge}"
  end

  def get_result(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request['Content-Type'] = 'application/json'
    request['User-Agent'] = 'openhub.net client'
    response = http.request(request)
    JSON.parse(response.body)
  end

  class << self
    def first(url)
      Forge.all.map { |f| f.match(url) }.compact.first
    end
  end
end
