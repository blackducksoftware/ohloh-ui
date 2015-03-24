class Forge::Match
  require 'open-uri'
  require 'json'

  attr_accessor :forge
  attr_accessor :owner_at_forge
  attr_accessor :name_at_forge

  def initialize(forge, owner_at_forge, name_at_forge)
    @forge = forge
    @owner_at_forge = owner_at_forge
    @name_at_forge = name_at_forge
  end

  def get_json_api
    json_api_url = forge.json_api_url(self)
    return {} unless json_api_url
    @json ||= JSON.parse(open(json_api_url, 'User-Agent' => 'Ohloh.net client').read)
  end

  def project
    Project.new(forge.get_project_attributes(self))
  end

  def repositories
    forge.get_repository_attributes(self).map do |r|
      r[:type] ? r[:type].new(r.reject { |k, _| k == :type }) : nil
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
