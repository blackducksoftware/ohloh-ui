module BlogLinkHelper
  def blog_link_to(link:, link_text:)
    "<a class='meta' href='http://blog.openhub.net/#{BLOG_LINKS[link]}' target='_blank'>#{link_text}</a>".html_safe
  end

  def blog_url_for(article_name)
    path = BLOG_LINKS[article_name] || article_name.to_s
    "http//blog.openhub.net/#{path}"
  end
end
