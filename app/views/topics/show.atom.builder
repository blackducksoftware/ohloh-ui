atom_feed do |feed|
  xml.instruct!
  xml.rss do
    xml.channel do
      feed.title "Recent Posts in '#{@topic.title}' | Open Hub"
      feed.link "https://www.openhub.net" + topic_path(@topic)
      feed.language 'en-us'
      feed.ttl 60
      feed.description @topic.title
      # Note: Hacky fix for xml indentation. Gsub method indents xml properly.
      xml << render(partial: 'posts/posts.atom.builder', collection: @posts).gsub(/^/, '      ')
    end
  end
end
