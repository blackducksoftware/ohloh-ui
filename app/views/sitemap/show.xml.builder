# frozen_string_literal: true

time = Time.current.strftime('%Y-%m-%d')

xml.instruct!
xml.urlset(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9') do
  @objects.each do |object|
    xml.url do
      xml.loc url_for(controller: @sitemap[:ctrl], only_path: false, action: 'show', id: object.to_param)
      xml.lastmod time
      xml.changefreq 'daily'
      xml.priority @priority unless @priority.nil?
    end
  end
end
