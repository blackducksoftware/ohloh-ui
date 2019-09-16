# frozen_string_literal: true

module RssSubscriptionsHelper
  def last_fetch_detail(object)
    if object.rss_feed.last_fetch?
      t('.last_update', time: time_ago_in_words(object.rss_feed.last_fetch))
    else
      t('.never_updated')
    end
  end
end
