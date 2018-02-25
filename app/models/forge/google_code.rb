class Forge::GoogleCode < Forge
  require 'open-uri'
  require 'nokogiri'

  def match(url)
    case url
    when /\bcode\.google\.com(\/a\/([^\/]+))?\/p\/([^\/\.]+)\b/
      org_name = $2
      base_name = $3
      Forge::Match.new(self, org_name, base_name)
    when /\b([^\/\.]+)\.googlecode.com\/(svn|hg|git)\b/
      Forge::Match.new(self, nil, $1)
    end
  end

  def get_project_attributes(match)
    doc = Nokogiri::HTML get_homepage_html(match)
    { name: project_name(doc), vanity_url: match.name_at_forge,
      description: project_description(doc), url: homepage_html_url(match) }
  end

  def get_code_location_attributes(match)
    doc = Nokogiri::HTML get_source_html(match)
    type, url = repository_type_and_url(doc)
    [{ forge_match: match, scm_type: type, url: url }]
  end

  private

  # Google doesn't actually have an API. This URL leads to the basic project home page.
  def homepage_html_url(match)
    if match.owner_at_forge
      "http://code.google.com/a/#{match.owner_at_forge}/p/#{match.name_at_forge}/"
    else
      "http://code.google.com/p/#{match.name_at_forge}/"
    end
  end

  def get_homepage_html(match)
    open(homepage_html_url(match)).read
  end

  def source_html_url(match)
    "#{homepage_html_url(match)}source/checkout"
  end

  def get_source_html(match)
    open(source_html_url(match)).read
  end

  def project_name(doc)
    e = doc.css('#pname span[itemprop="name"]').first
    e && e.inner_html
  end

  def project_description(doc)
    e = doc.css('#psum span[itemprop="description"]').first
    e && e.inner_html
  end

  def repository_type_and_url(doc)
    e = doc.css('#checkoutcmd').first
    case e && e.inner_html
    when /svn checkout .+http.+(:\S+) .+/
      # HTML fragment contains <strong> and <em>, which must be stripped away
      [:svn_sync, "http#{$1}"]
    when /git clone (.+)/
      [:git, $1]
    when /hg clone (.+)/
      [:hg, $1]
    end
  end
end
