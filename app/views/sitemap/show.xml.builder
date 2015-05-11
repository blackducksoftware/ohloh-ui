xml.instruct!
xml.urlset(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9') do
  @urls.each do |url|
    xml.url do
      xml.loc url
      xml.lastmod @time
      xml.changefreq 'daily'
      xml.priority @priority unless @priority.nil?
    end
  end
end
