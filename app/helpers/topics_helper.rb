module TopicsHelper
  def next_topic?(collection_of_all_topics, topic)
    !(topic == collection_of_all_topics.last)
  end

  def next_topic(collection_of_all_topics, topic)
    return '' unless next_topic?(collection_of_all_topics, topic)
    topic_path(collection_of_all_topics[(collection_of_all_topics.index(topic) + 1)])
  end

  def previous_topic(collection_of_all_topics, topic)
    topic_path(collection_of_all_topics[(collection_of_all_topics.index(topic) - 1)])
  end
end
