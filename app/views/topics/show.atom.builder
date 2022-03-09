# frozen_string_literal: true

atom_feed do |feed|
  xml.instruct!
  xml.rss do
    xml.channel do
      feed.title "Recent Posts in '#{@topic.title}' | Open Hub"
      feed.link "https://www.openhub.net#{topic_path(@topic)}"
      feed.language 'en-us'
      feed.ttl 60
      feed.description @topic.title
      render partial: 'posts/posts', collection: @posts, xml: feed
    end
  end
end
