time = Time.current.strftime('%Y-%m-%d')

xml.instruct!
xml.sitemapindex(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9') do
  @sites.each do |site|
    xml.sitemap do
      xml.loc "#{request.protocol}#{request.host}/sitemaps/#{site}"
      xml.lastmod time
    end
  end
end
