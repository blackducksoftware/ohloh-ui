class Forge::SourceForge < Forge
  attr_accessor :url

  def match(url)
    @url = url
    case @url
    # Source control URL
    when /\b([^@\/\.]+)\.(cvs|svn|hg|git|bzr)\.(sourceforge|sf)\.net\b/
      Forge::Match.new(self, nil, $1)
    # Project web page URL, project name in path
    when /\b(sourceforge|sf)\.net\/(projects|p)\/([^\/\.]+)\b/
      Forge::Match.new(self, nil, $3)
    # Project web page URL, project name in subdomain
    when /\b([^\/\.]+)\.(sourceforge|sf)\.net\b/
      Forge::Match.new(self, nil, $1)
    end
  end

  def json_api_url(match)
    "http://sourceforge.net/rest/p/#{match.name_at_forge}/"
  end

  def get_project_attributes(match)
    json = match.get_json_api
    { name: json['name'], url_name: match.name_at_forge, description: json['short_description'],
      url: json['external_homepage'] || json['url'] }
  end

  # Returns an array of hashes of repository attributes, one per repository.
  def get_repository_attributes(match)
    json = match.get_json_api
    mount_point = get_mount_point(json)
    return [] unless mount_point.length > 0
    repo_type = mount_point.first['name']
    if repo_type == 'cvs'
      location = @url
    else
      location = "#{repo_type}://#{repo_type}.code.sf.net/p/#{match.name_at_forge}/#{mount_point.first['mount_point']}"
    end
    fetch_repo_attrs(match, repo_type, location)
  end

  private

  def get_mount_point(json)
    Array(json['tools']).select do |i|
      i['name'] =~ /cvs|svn|hg|git|bzr/
    end
  end

  def repo_class(type)
    { svn: SvnSyncRepository, hg: HgRepository, git: GitRepository, cvs: CvsRepository }[type.to_sym]
  end

  def fetch_repo_attrs(match, type, location)
    [{ forge_match: match, type: repo_class(type), url: location }]
  end
end
