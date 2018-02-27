class Forge::Match
  require 'open-uri'
  require 'json'

  MAX_FORGE_COMM_TIME = 10

  attr_accessor :forge
  attr_accessor :owner_at_forge
  attr_accessor :name_at_forge

  def initialize(forge, owner_at_forge, name_at_forge)
    @forge = forge
    @owner_at_forge = owner_at_forge
    @name_at_forge = name_at_forge
  end

  def forge_id
    forge && forge.id
  end

  def get_json_api
    json_api_url = forge.json_api_url(self)
    return {} unless json_api_url
    @json ||= JSON.parse(open(json_api_url, 'User-Agent' => 'Ohloh.net client').read)
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

  class << self
    def first(url)
      Forge.all.map { |f| f.match(url) }.compact.first
    end
  end
end
