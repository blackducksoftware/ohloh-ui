module ApplicationHelper
  def blog_link_to(name:, link_text:)
    "<a class='meta' href='http://blog.openhub.net/#{name}' target='_blank'>#{link_text}</a>"
  end
end
