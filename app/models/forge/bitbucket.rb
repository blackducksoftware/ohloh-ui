class Forge::Bitbucket < Forge
  def match(url)
    matches = /\bbitbucket\.org\/([^\/]+)\/([^\/\.]+)\b/.match(url)
    return nil unless matches
    owner_name = matches[1]
    base_name = matches[2]
    Forge::Match.new(self, owner_name, base_name)
  end

  def json_api_url(match)
    "https://api.bitbucket.org/1.0/repositories/#{match.owner_at_forge}/#{match.name_at_forge}"
  end

  def get_project_attributes(match)
    json = match.get_json_api
    { name: json['name'], vanity_url: match.name_at_forge, description: json['description'], url: json['website'] }
  end

  def get_code_location_attributes(match)
    [{ scm_type: :hg,
       url: "https://bitbucket.org/#{match.owner_at_forge}/#{match.name_at_forge}",
       forge_match: match }]
  end
end
