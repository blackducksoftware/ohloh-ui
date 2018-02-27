class Forge::Github < Forge
  def match(url)
    case url
    when /\bgithub\.com[:\/]([^\/\.]+)\/([^\/]+)\b/
      owner_name = $1
      base_name = $2
      Forge::Match.new(self, owner_name, base_name.gsub('.git', ''))
    end
  end

  def json_api_url(match)
    uri = "https://api.github.com/repos/#{match.owner_at_forge}/#{match.name_at_forge}"
    uri += "?access_token=#{ENV['GITHUB_AUTH_TOKEN']}" if ENV['GITHUB_AUTH_TOKEN']
    uri
  end

  def get_project_attributes(match)
    json = match.get_json_api
    url = json['homepage'].to_s.empty? ? json['html_url'] : json['homepage']
    { name: json['name'], vanity_url: match.name_at_forge, description: json['description'], url: url }
  end

  def get_code_location_attributes(match)
    json = match.get_json_api
    [{ scm_type: :git, forge_match: match, branch: json['master_branch'], url: json['git_url'] }]
  end
end
