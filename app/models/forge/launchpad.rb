class Forge::Launchpad < Forge
  def match(url)
    case url
    when /\b(lp:|((bazaar|code)?\.launchpad\.net\/))(~([^\/]+)\/)?([^~\/]+)(\/([^\/+]+))?\b/
      owner_name = $5
      base_name = $6
      Forge::Match.new(self, owner_name, base_name)
    when /\blaunchpad\.net[:\/]([^\/\.]+)\b/
      Forge::Match.new(self, nil, $1)
    end
  end

  def json_api_url(match)
    "https://api.launchpad.net/1.0/#{match.name_at_forge}"
  end

  def get_project_attributes(match)
    json = match.get_json_api
    { name: json['title'] || json['name'], vanity_url: match.name_at_forge,
      description: json['description'] || json['summary'],
      url: json['homepage_url'], download_url: json['download_url'] }
  end

  def get_code_location_attributes(match)
    doc = Nokogiri::HTML get_homepage_html(match)
    url = repository_url(doc)
    url ? [{ scm_type: :bzr, forge_match: match, url: url }] : []
  end

  private

  def homepage_html_url(match)
    "https://launchpad.net/#{match.name_at_forge}"
  end

  def get_homepage_html(match)
    open(homepage_html_url(match)).read
  end

  def repository_url(doc)
    a = doc.css('dl#dev-focus dd a.branch').first
    return nil unless a

    # If link text has shorthand form 'lp:xxx', use that. Else, use the link href
    if a.inner_html =~ /lp:.+/
      a.inner_html
    else
      a.attributes['href'].value
    end
  end
end
